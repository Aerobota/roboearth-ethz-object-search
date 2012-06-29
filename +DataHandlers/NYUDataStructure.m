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
            error('NYUDataStructure:notImplemented','Method not implemented')
        end
        function save(obj,path)
            error('NYUDataStructure:notImplemented','Method not implemented')
        end
    end
end