classdef DataStructure<handle
    %DATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(Access='protected')
        data
        storageName
        classes
        nameIndex
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
        trainSet
        testSet
        gt
        det
        catFileName
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
        function obj=DataStructure(path,testOrTrain,gtOrDet,preallocationSize)
            tmpCell=cell(1,preallocationSize);
            obj.data=struct('filename',tmpCell,'depthname',tmpCell,...
                'folder',tmpCell,'imagesize',tmpCell,'calib',tmpCell,'objectPath',tmpCell);%,'object',tmpCell
            
            obj.path=path;
            obj.setChooser={testOrTrain gtOrDet};
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
        
        function index=name2Index(obj,name)
            [~,index]=ismember(name,{obj.data.filename});
            assert(index>0,'Image %s doesn''t exist in this dataset',name);
        end
        
        function writeNameListFile(obj,nameListFile)
            fid=fopen(nameListFile,'wt');
            for n=1:length(obj)
                fprintf(fid,'%s\n',obj.getFilename(n));
            end
            fclose(fid);            
        end
        
        function reduceDataStructure(obj,indexer)
            toRemove=1:length(obj);
            toRemove(indexer)=[];
            for i=toRemove
                obj.removeObject(i);
            end
            obj.data=obj.data(indexer);
        end
        
        function addData(obj,otherDataStructure)
            assert(isa(otherDataStructure,'DataHandlers.DataStructure'));
            obj.data=[obj.data otherDataStructure.data];
        end
        
        %% Get Functions
        function names=getClassNames(obj)
            if isempty(obj.classes)
                obj.loadClasses();
            end
            names=obj.classes;
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
            for i=length(in.names):-1:1
                obj.classes{i}=in.names{i};
            end
        end
    end
    
    %% Utility Functions
    methods(Static)
        function overlap=computeOverlap(detObjects,gtObjects,mode)
            assert(ismember(mode,{'complete','exclusive'}),'DataStructure:wrongInput',...
                'The mode argument must be ''complete'' or ''exclusive''.')
            if strcmp(mode,'complete')
                modeComplete=true;
            else
                modeComplete=false;
            end
            
            overlap=zeros(size(detObjects));
            for i=1:length(gtObjects)
                if ~modeComplete
                    maxOverlap=0;
                    maxIndex=0;
                end
                gtBB=[min(gtObjects(i).polygon.x) max(gtObjects(i).polygon.x);...
                    min(gtObjects(i).polygon.y) max(gtObjects(i).polygon.y)];
                for j=1:length(detObjects)
                    if strcmpi(detObjects(j).name,gtObjects(i).name)
                        detBB=[min(detObjects(j).polygon.x) max(detObjects(j).polygon.x);...
                            min(detObjects(j).polygon.y) max(detObjects(j).polygon.y)];
                        unionArea=max(min(gtBB(1,2),detBB(1,2))-max(gtBB(1,1),detBB(1,1)),0)*...
                            max(min(gtBB(2,2),detBB(2,2))-max(gtBB(2,1),detBB(2,1)),0);
                        tmpOverlap=unionArea/((gtBB(1,2)-gtBB(1,1))*(gtBB(2,2)-gtBB(2,1))+...
                            (detBB(1,2)-detBB(1,1))*(detBB(2,2)-detBB(2,1))-unionArea);
                        
                        if modeComplete
                            overlap(j)=max(overlap(j),tmpOverlap);
                        elseif maxOverlap<tmpOverlap
                            maxOverlap=tmpOverlap;
                            maxIndex=j;
                        end
                    end
                end
                if ~modeComplete
                    if maxIndex>0
                        overlap(maxIndex)=maxOverlap;
                    end
                end
            end
        end
    end
    
end

