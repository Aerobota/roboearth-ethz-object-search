classdef DataStructure<handle
    %DATASTRUCTURE Abstract class that stores a dataset
    %   This class is a container for arbitrary datasets than can be
    %   converted to its format.
    %
    %   The LOAD and SAVE methods have to be implemented to be able to load
    %   an arbitrary dataset.
    %
    %   The ADDIMAGE method supplies an interface to convert input data
    %   into the internal data structure. ADDIMAGE should be used instead
    %   of writing DATASTRUCTURE.DATA directly. It is allowed to store
    %   DATASTRUCTURE.DATA to disk using SAVE and retrieve it again during
    %   LOAD (for an example see DATAHANDLERS.NYUDATASTRUCTURE).
    %
    %   If all abstract methods and properties are correctly implemented in
    %   a derived class and ADDIMAGE has been used to generate the DATA
    %   property, most methods in EVALUATION and LEARNFUNC should work
    %   with the derived data structure.
    %
    %   For example implementation see DATAHANDLERS.NYUDATASTRUCTURE.
    
    %% Properties
    properties(Access='protected')
        data
        storageName
        classes
        classesLarge
        classesSmall
        class2ind
    end
    
    properties(SetAccess='protected')
        path
        setChooser
    end
    
    properties(Constant)
        objectFolder='object'
        objectTag='obj_'
        depthFolder='depth'
    end
    
    %% Abstract Methods and Properties
    properties(Abstract,Constant)
        imageFolder
        catFileName
        testSet
        trainSet
    end
    
    methods(Abstract)
        load(obj)
        save(obj)
    end
    
    methods(Abstract,Access='protected')
        name=getStorageName(obj);
        name=getObjectSubfolderName(obj)
        out=getPathToObjects(obj)
    end
    
    %% Data Loading
    methods
        function obj=DataStructure(path,testOrTrain)
            %OBJ=DATASTRUCTURE(PATH,TESTORTRAIN)
            %   Construct an empty dataset container. The data will be
            %   loaded from or saved in the folder specified by PATH.
            %   TESTORTRAIN is a string containing 'test' or 'train'
            %   depending on which part of the dataset should be loaded.
            %
            %   The container is empty needs to be loaded using OBJ.LOAD().
            assert(any(strcmpi(testOrTrain,{'test','train'})),'DataStructure:wrongInput',...
                'The testOrTrain argument must be ''test'' or ''train''.')
            
            tmpCell=cell(1,0);
            % Generate preallocated data structure
            obj.data=struct('filename',tmpCell,'depthname',tmpCell,...
                'folder',tmpCell,'imagesize',tmpCell,'calib',tmpCell,'objectPath',tmpCell);
            
            % Save constructor input in properties
            obj.path=path;
            obj.setChooser=testOrTrain;
            obj.storageName=obj.getStorageName();
        end
        function addImage(obj,index,filename,depthname,folder,imagesize,object,calib)
            %ADDIMAGE(OBJ,INDEX,FILENAME,DEPTHNAME,FOLDER,IMAGESIZE,OBJECT,CALIB)
            %   This is the main interface to add an additional scene or
            %   image to the data structure.
            %
            %   INDEX is the index of the new image.
            %   FILENAME is the filename of the image file.
            %   DEPTHFILE is the filename of the depth file.
            %   FOLDER is the name of the subdirectory of the image and
            %   depth files, this is an empty string most of the time.
            %   IMAGESIZE is a struct with the fields 'nrows' and 'ncols'
            %   or a vector of length two. They contain the height and
            %   width of the image in pixels.
            %   OBJECT is an array of OBJECT3DSTRUCTURE containing the
            %   objects occurring in the scene.
            %
            %   See also DATAHANDLERS.OBJECT3DSTRUCTURE.
            assert(ischar(filename),'DataStructure:wrongInput',...
                'The filename argument must be a character array.')
            assert(ischar(depthname),'DataStructure:wrongInput',...
                'The depthname argument must be a character array.')
            assert(ischar(folder),'DataStructure:wrongInput',...
                'The folder argument must be a character array.')
            assert((isfield(imagesize,'nrows') && isfield(imagesize,'ncols')) ||...
                (isvector(imagesize) && length(imagesize)>1 && isnumeric(imagesize)),...
                'DataStructure:wrongInput','The imagesize argument must be a vector of length two or a struct with fields {nros,ncols}.')
            assert(isa(object,'DataHandlers.Object3DStructure'),'DataStructure:wrongInput',...
                'The object argument must be of ObjectStructure class.')
            assert((isnumeric(calib) && all(size(calib)==[3 3])) || isempty(calib),'DataStructure:wrongInput',...
                'The calib argument must be a 3x3 or empty matrix.')
            
            obj.data(index).filename=filename;
            obj.data(index).depthname=depthname;
            obj.data(index).folder=folder;
            if length(imagesize)>1
                obj.data(index).imagesize.nrows=imagesize(1);
                obj.data(index).imagesize.ncols=imagesize(2);
            else
                obj.data(index).imagesize=imagesize;
            end
            obj.setObject(object,index);
            obj.data(index).calib=calib;
        end
        
        %% Support Functions
        function s=size(obj,index)
            %SIZE is a simple overload of the standard size function
            if nargin<2
                s=size(obj.data);
            else
                s=size(obj.data,index);
            end
        end
        
        function l=length(obj)
            %LENGTH is a simple overload of the standard length function
            l=length(obj.data);
        end
        
        function index=className2Index(obj,name)
            %INDEX=CLASSNAME2INDEX(OBJ,NAME)
            %   The returned INDEX is guaranteed to be unique for the class
            %   NAME during the lifetime of the data structure. The function
            %   throws an error if NAME contains a string that doesn't map
            %   to a saved class name.
            %   NAME can be a simple string or a cell string array. If it's
            %   an array Size(INDEX)==Size(NAME).
            
            % If the classes haven't been loaded yet, do so now
            if isempty(obj.classes)
                obj.loadClasses();
            end
            
            % Use fieldnames to get the correct indices
            if isempty(name)
                index=[];
            elseif iscellstr(name)
                for i=length(name):-1:1
                    index(1,i)=obj.class2ind.(name{i});
                end
            else
                index=obj.class2ind.(name);
            end
        end
        
        function reduceDataStructure(obj,indexer)
            % REDUCEDATASTRUCTURE(OBJ,INDEXER)
            %   Keep only the images denoted by INDEXER. All other images
            %   are permanentely removed from disk.
            toRemove=1:length(obj);
            toRemove(indexer)=[];
            % Remove object, depth and image files
            for i=toRemove
                obj.removeObject(i);
                imgFile=fullfile(obj.path,obj.imageFolder,obj.getFolder(i),obj.getFilename(i));
                if exist(imgFile,'file')==2
                    delete(imgFile);
                end
                depthFile=fullfile(obj.path,obj.depthFolder,obj.getFolder(i),obj.getDepthname(i));
                if exist(depthFile,'file')==2
                    delete(depthFile);
                end
            end
            % Remove the data
            obj.data=obj.data(indexer);
            % Save changes
            obj.save();
        end
        
        %% Utility Functions
        
        function pos=get3DPositionForImage(obj,index)
            %POS=GET3DPOSITIONFORIMAGE(OBJ,INDEX)
            %   POS contains the 3D positions of every pixel of image
            %   INDEX. POS is a 3xn matrix where is the total number of
            %   pixels in the image.
            
            % Laod the depth data
            depthImage=obj.getDepthImage(index);
            
            % Get the pixel indices
            [tmpX,tmpY]=meshgrid(1:size(depthImage,1),1:size(depthImage,2));
            tmpX=tmpX';
            tmpY=tmpY';

            % Generate 2D homogeneous coordinates
            pos=[tmpX(:)';tmpY(:)';ones(1,numel(tmpX))];
            % Apply calibration matrix to get normalized 2D coordinates
            pos=obj.getCalib(index)\pos;

            % Scale every dimension by the depth to get 3D
            for d=1:3
                pos(d,:)=pos(d,:).*depthImage(tmpX(:)'+(tmpY(:)'-1)*size(tmpX,1));
            end
        end
        
        %% Get Functions
        function names=getClassNames(obj)
            if isempty(obj.classes)
                obj.loadClasses();
            end
            names=obj.classes;
        end
        
        function names=getLargeClassNames(obj)
            if isempty(obj.classesLarge)
                obj.loadClasses();
            end
            names=obj.classesLarge;
        end
        function names=getSmallClassNames(obj)
            if isempty(obj.classesSmall)
                obj.loadClasses();
            end
            names=obj.classesSmall;
        end
    
        function out=getFilename(obj,i)
            out=obj.data(i).filename;
        end
        
        function out=getDepthname(obj,i)
            out=obj.data(i).depthname;
        end
        
        function out=getFolder(obj,i)
            out=obj.data(i).folder;
        end
        
        function out=getImagesize(obj,i)
            out=obj.data(i).imagesize;
        end
        
        function out=getObject(obj,i)
            tmpPath=fullfile(obj.getPathToObjects(),obj.data(i).objectPath);
            loaded=load(tmpPath);
            out=loaded.object;
        end
        
        function out=getCalib(obj,i)
            out=obj.data(i).calib;
        end
        
        function img=getColourImage(obj,i)
            img=imread(fullfile(obj.path,obj.imageFolder,obj.getFolder(i),obj.getFilename(i)));
        end
        
        function img=getDepthImage(obj,i)
            loaded=load(fullfile(obj.path,obj.depthFolder,obj.getFolder(i),obj.getDepthname(i)));
            img=loaded.depth;
        end
        %% Set Functions
        function setObject(obj,newObject,i)
            %SETOBJECT(OBJ,NEWOBJECT,I)
            %   Replace the current OBJECT3DSTRUCTURE array of image I with
            %   NEWOBJECT.
            assert(isa(newObject,'DataHandlers.Object3DStructure'),'DataStructure:wrongInput',...
                'The newObject argument must be of ObjectStructure class.')
            % Generate the filename
            tmpPath=fullfile(obj.getPathToObjects(),obj.data(i).objectPath);
            % If the object file doesn't exist yet create a new one
            if exist(tmpPath,'file')~=2
                tmpName=obj.getObjectSubfolderName();
                tmpDir=fullfile(obj.getPathToObjects(),obj.objectFolder,tmpName);
                if ~exist(tmpDir,'dir')
                    [~,~,~]=mkdir(tmpDir);
                end
                tmpName=fullfile(obj.objectFolder,tmpName,[obj.objectTag num2str(i,'%05d') '.mat']);
                obj.data(i).objectPath=tmpName;
                tmpPath=fullfile(obj.getPathToObjects(),obj.data(i).objectPath);
            end
            % Save the newObject
            saver.object=newObject;
            save(tmpPath,'-struct','saver');
        end
    end
    
    %% Protected Data Loading
    methods(Access='protected',Sealed)
        function loadClasses(obj)
            % Load the classes from file
            tmpPath=fullfile(obj.path,obj.catFileName);
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath);
            obj.classes=genvarname(in.names);
            obj.classesLarge=genvarname(in.largeNames);
            obj.classesSmall=genvarname(in.smallNames);
            
            obj.generateClassIndexLookup();
        end
        
        function generateClassIndexLookup(obj)
            for i=1:length(obj.classes)
                obj.class2ind.(obj.classes{i})=i;
            end
        end
        
        
    %% Remove Functions
        function removeObject(obj,i)
            tmpPath=fullfile(obj.getPathToObjects(),obj.data(i).objectPath);
            if exist(tmpPath,'file')==2
                delete(tmpPath);
            end
        end
    end
end

