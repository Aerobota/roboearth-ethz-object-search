classdef SunLoader<DataHandlers.DataLoader
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(Constant)
        catFileName='sun09_objectCategories.mat';
        imageFolder='Images'
    end
    
    %% Interface
    methods
        function obj=SunLoader(filePath,classes)
            obj=obj@DataHandlers.DataLoader(filePath);
            if nargin<2
                obj.classes=obj.getClasses();
            else
                obj.classes=classes;
            end
        end
        function out=getData(obj,desiredSet)
            tmpPath=fullfile(obj.path,desiredSet{2});
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath,desiredSet{1});
            out=in.(desiredSet{1});
        end
    end
    
    %% Internal methods for loading
    methods(Access='protected')
        function classes=getClasses(obj)
            tmpPath=fullfile(obj.path,obj.catFileName);
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath);
            classes(length(in.names),1).name=in.names{end};
            for i=1:length(in.names)
                classes(i).name=in.names{i};
                classes(i).height=in.heights(i);
            end
        end
    end
    
    %% Methods for file conversion
    methods(Access='protected')
        function data=removeAliasesImpl(~,data,alias)
            for i=1:length(data)
                for o=1:length(data(i).annotation.object)
                    try
                        data(i).annotation.object(o).name=genvarname(data(i).annotation.object(o).name);
                        data(i).annotation.object(o).name=alias.(data(i).annotation.object(o).name);
                    catch
                    end
                end
            end
        end
    end
    
end

