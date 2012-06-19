classdef CompoundPath
    %% Properties
    properties(SetAccess='protected')
        tag;
        path;
        ext
    end
    %% Public Methods
    methods
        function obj=CompoundPath(newTag,newPath,newExtension)
            obj.tag=newTag;
            if newPath(end)~=filesep
                obj.path=[newPath filesep];
            else
                obj.path=newPath;
            end
            if newExtension(1)~='.'
                obj.ext=['.' newExtension];
            else
                obj.ext=newExtension;
            end
        end
        function p=getPath(obj,name,additionalPath)
            if nargin<3
                additionalPath=[];
            elseif additionalPath(end)~=filesep
                additionalPath=[additionalPath filesep];
            end
                
            p=[additionalPath obj.path obj.getFileName(name)];
        end
        function n=getFileName(obj,name)
            n=[obj.tag name obj.ext];
        end
    end
end