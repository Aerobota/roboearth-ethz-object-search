classdef NYULoader<DataHandlers.DataLoader
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        data
        names
    end
    
    properties(Constant)
        catFileName='objectCategories.mat';
        imageFolder='image'
        depthFolder='depth'
    end
    
    methods
        function obj=NYULoader(filePath)
            obj=obj@DataHandlers.DataLoader(filePath);
            obj.classes=obj.getClasses();
        end
        function out=getData(obj,desiredSet)
            tmpPath=fullfile(obj.path,desiredSet{2});
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath,desiredSet{1});
            out=in.(desiredSet{1});
        end
        function image=getDataByName(obj,name)
            assert(~isempty(obj.names),'To access data by name the dataset needs to be buffered')
            image=obj.data(ismember(obj.names,name));
            assert(~isempty(image),'Image %s doesn''t exist in this dataset',name);
            if(size(image,2)~=1)
                image=image(1);
            end
        end
        function bufferDataset(obj,desiredSet,nameListFile)
            obj.data=obj.getData(desiredSet);
            for i=length(obj.data):-1:1
                obj.names{1,i}=obj.data(i).annotation.filename;
            end
            
            if nargin>=3
                fid=fopen(nameListFile,'wt');
                for n=1:length(obj.names)
                    fprintf(fid,'%s\n',obj.names{n});
                end
                fclose(fid);
            end
        end
    end
    methods(Access='protected')
        function classes=getClasses(obj)
            tmpPath=fullfile(obj.path,obj.catFileName);
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath);
            classes(length(in.names),1).name=in.names{end};
            for i=1:length(in.names)
                classes(i).name=in.names{i};
            end
        end
    end
    
end