classdef NYUDataStructure<DataHandlers.DataStructure
    %NYUDATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=NYUDataStructure(path,preallocationSize)
            if nargin<2
                preallocationSize=0;
            end
            obj=obj@DataHandlers.DataStructure(path,preallocationSize);
        end
        function load(obj)
            assert(exist(obj.filePath,'file')>0,'DataStructure:fileNotFound',...
                'The file %s doesn''t exist.',obj.filePath)
            loaded=load(obj.filePath);
            obj.data=loaded.data;
        end
        function save(obj)
            if ~exist(obj.dataPath,'dir')
                [~,~,~]=mkdir(obj.dataPath);
            end
            tmpObj.data=obj.data;
            save(obj.filePath,'-struct','tmpObj');
        end
        function newObject=getSubset(obj,indexer)
            newObject=DataHandlers.NYUDataStructure();
            newObject.data=obj.data(indexer);
        end
    end
    
end