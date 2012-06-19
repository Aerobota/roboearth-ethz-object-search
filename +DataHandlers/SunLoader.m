classdef SunLoader<DataHandlers.DataLoader
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        catFileName='sun09_objectCategories.mat';
        imageFolder='Images'
%         trainSet={'Dtraining';'sun09_groundTruth.mat'}
%         testSet={'Dtest';'sun09_groundTruth.mat'}
    end
    
    methods
        function obj=SunLoader(filePath)
            obj=obj@DataHandlers.DataLoader(filePath);
            obj.classes=obj.getClasses();
        end
        function out=getData(obj,desiredSet)
            tmpPath=fullfile(obj.path,desiredSet{2});
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath,desiredSet{1});
            out=in.(desiredSet{1});
        end
    end
    methods(Access='protected')
        function classes=getClasses(obj)
            tmpPath=fullfile(obj.path,DataHandlers.SunLoader.catFileName);
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath);
            classes(length(in.names),1).name=in.names{end};
            for i=1:length(in.names)
                classes(i).name=in.names{i};
                classes(i).height=in.heights(i);
            end
        end
    end
    
end

