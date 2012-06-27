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
            obj.path=newPath;
            obj.ext=newExtension;
        end
        function p=getPath(obj,name,additionalPath)
            if nargin<3
                additionalPath=[];
            end
                
            p=fullfile(additionalPath,obj.path,obj.getFileName(name));
        end
        function n=getFileName(obj,name)
            n=[obj.tag name obj.ext];
        end
    end
end