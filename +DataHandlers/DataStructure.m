classdef DataStructure<handle
    %DATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access='protected')
        data
        dataPath
        filePath
    end
    
    properties(Constant)
        objectFolder='object'
        objectTag='obj_'
    end
    
    methods(Abstract)
        load(obj)
        save(obj)
        subset=getSubset(obj,indexer)
    end
    
    methods
        function obj=DataStructure(path,preallocationSize)
            tmpCell=cell(1,preallocationSize);
            obj.data=struct('filename',tmpCell,'depthname',tmpCell,...
                'folder',tmpCell,'imagesize',tmpCell,'calib',tmpCell,'objectPath',tmpCell);%,'object',tmpCell
            
            [obj.dataPath,~,~]=fileparts(path);
            obj.filePath=path;
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
%             obj.data(index).object=object;
            obj.data(index).calib=calib;
        end
        
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
            tmpPath=fullfile(obj.dataPath,obj.data(i).objectPath);
            loaded=load(tmpPath);
            out=loaded.object;
        end
        
        function out=getObjectOld(obj,i)
            out=obj.data(i).object;
        end
        
        function setObject(obj,newObject,i)
            assert(isa(newObject,'DataHandlers.ObjectStructure'),'DataStructure:wrongInput',...
                'The newObject argument must be of ObjectStructure class.')
            tmpPath=fullfile(obj.dataPath,obj.data(i).objectPath);
            tmpDir=fullfile(obj.dataPath,obj.objectFolder);
            if exist(tmpPath,'file')~=2
                if ~exist(tmpDir,'dir')
                    [~,~,~]=mkdir(tmpDir);
                end
                [~,tmpName,~]=fileparts(obj.filePath);
                tmpDir=fullfile(obj.dataPath,obj.objectFolder,tmpName);
                if ~exist(tmpDir,'dir')
                    [~,~,~]=mkdir(tmpDir);
                end
                tmpName=fullfile(obj.objectFolder,tmpName,[obj.objectTag num2str(i,'%05d') '.mat']);
                obj.data(i).objectPath=tmpName;
                tmpPath=fullfile(obj.dataPath,obj.data(i).objectPath);
            end
            saver.object=newObject;
            save(tmpPath,'-struct','saver');
        end
        
        function out=getCalib(obj,i)
            out=obj.data(i).calib;
        end
        
%         function out=horzcat(a,b)
%             out=a;
%             a.data=[a.data b.data];
%         end
    end
    
end

