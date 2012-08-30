classdef DataStructure<handle
    %DATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
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
        function obj=DataStructure(path,testOrTrain,preallocationSize)
            assert(any(strcmpi(testOrTrain,{'test','train'})),'DataStructure:wrongInput',...
                'The testOrTrain argument must be ''test'' or ''train''.')
            
            tmpCell=cell(1,preallocationSize);
            obj.data=struct('filename',tmpCell,'depthname',tmpCell,...
                'folder',tmpCell,'imagesize',tmpCell,'calib',tmpCell,'objectPath',tmpCell);%,'object',tmpCell
            
            obj.path=path;
            obj.setChooser=testOrTrain;
            obj.storageName=obj.getStorageName();
        end
        function addImage(obj,index,filename,depthname,folder,imagesize,object,calib)
            assert(ischar(filename),'DataStructure:wrongInput',...
                'The filename argument must be a character array.')
            assert(ischar(depthname),'DataStructure:wrongInput',...
                'The depthname argument must be a character array.')
            assert(ischar(folder),'DataStructure:wrongInput',...
                'The folder argument must be a character array.')
            assert((isfield(imagesize,'nrows') && isfield(imagesize,'ncols')) ||...
                (isvector(imagesize) && length(imagesize)>1 && isnumeric(imagesize)),...
                'DataStructure:wrongInput','The imagesize argument must be a vector of length two or a struct with fields {nros,ncols}.')
            assert(isa(object,'DataHandlers.ObjectStructure'),'DataStructure:wrongInput',...
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
            if nargin<2
                s=size(obj.data);
            else
                s=size(obj.data,index);
            end
        end
        
        function l=length(obj)
            l=length(obj.data);
        end
        
        function index=className2Index(obj,name)
            if isempty(obj.classes)
                obj.loadClasses();
            end
            
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
            toRemove=1:length(obj);
            toRemove(indexer)=[];
            for i=toRemove
                obj.removeObject(i);
            end
            obj.data=obj.data(indexer);
        end
        
        %% Utility Functions
        
        function pos=get3DPositionForImage(obj,index)
            depthImage=obj.getDepthImage(index);

            [tmpX,tmpY]=meshgrid(1:size(depthImage,1),1:size(depthImage,2));
            tmpX=tmpX';
            tmpY=tmpY';

            pos=[tmpX(:)';tmpY(:)';ones(1,numel(tmpX))];
            pos=obj.getCalib(index)\pos;

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
            assert(isa(newObject,'DataHandlers.ObjectStructure'),'DataStructure:wrongInput',...
                'The newObject argument must be of ObjectStructure class.')
            tmpPath=fullfile(obj.getPathToObjects(),obj.data(i).objectPath);
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
            saver.object=newObject;
            save(tmpPath,'-struct','saver');
        end
        %% Remove Functions
        function removeObject(obj,i)
            tmpPath=fullfile(obj.getPathToObjects(),obj.data(i).objectPath);
            if exist(tmpPath,'file')==2
                delete(tmpPath);
            end
        end
    end
    
    %% Protected Data Loading
    methods(Access='protected',Sealed)
        function loadClasses(obj)
            tmpPath=fullfile(obj.path,obj.catFileName);
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath);
            obj.classes=in.names;
            obj.classesLarge=in.largeNames;
            obj.classesSmall=in.smallNames;
            
            obj.generateClassIndexLookup();
        end
        
        function generateClassIndexLookup(obj)
            for i=1:length(obj.classes)
                obj.class2ind.(obj.classes{i})=i;
            end
        end
    end
end

