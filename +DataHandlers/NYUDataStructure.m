classdef NYUDataStructure<DataHandlers.DataStructure
    %NYUDATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=NYUDataStructure(preallocationSize)
            if nargin<1
                preallocationSize=0;
            end
            obj=obj@DataHandlers.DataStructure(preallocationSize);
        end
        function load(obj,path)
            assert(exist(path,'file')>0,'DataStructure:fileNotFound',...
                'The file %s doesn''t exist.',path)
            loaded=load(path);
            obj.data=loaded.data;
        end
        function save(obj,path)
            [tmpDir,~,~]=fileparts(path);
            if ~exist(tmpDir,'dir')
                [~,~,~]=mkdir(tmpDir);
            end
            tmpObj.data=obj.data;
            save(path,'-struct','tmpObj');
        end
        function newObject=getSubset(obj,indexer)
            newObject=DataHandlers.NYUDataStructure();
            newObject.data=obj.data(indexer);
        end
    end
    
end