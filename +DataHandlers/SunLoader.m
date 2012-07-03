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
            out=DataHandlers.SunDataStructure(desiredSet{1});
            out.load(tmpPath);
        end
    end
    
    %% Internal methods for loading
%     methods(Access='protected')
%         function classes=getClasses(obj)
%             tmpPath=fullfile(obj.path,obj.catFileName);
%             assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
%             in=load(tmpPath);
%             classes(length(in.names),1).name=in.names{end};
%             for i=1:length(in.names)
%                 classes(i).name=in.names{i};
%                 classes(i).height=in.heights(i);
%             end
%         end
%     end
    
    %% Methods for file conversion
    methods(Access='protected')
        function data=removeAliasesImpl(~,data,alias)
            for i=1:length(data)
                tmpObjects=data.getObject(i);
                for o=1:length(tmpObjects)
                    tmpName=genvarname(tmpObjects(o).name);
                    try
                        tmpName=alias.(tmpName);
                    catch
                    end
                    tmpObjects(o)=DataHandlers.ObjectStructure(tmpName,tmpObjects(o).score,...
                        tmpObjects(o).polygon.x,tmpObjects(o).polygon.y);
                end
                data.setObject(tmpObjects,i);
            end
        end
    end
    
end

