classdef SunLoader<handle
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        path;
        objects;
    end
    properties(Constant)
        catFileName='sun09_objectCategories.mat';
        detTrain={'DdetectorTraining';'sun09_detectorOutputs.mat'};
        detTest={'DdetectorTest';'sun09_detectorOutputs.mat'}
        gtTrain={'Dtraining';'sun09_groundTruth.mat'}
        gtTest={'Dtest';'sun09_groundTruth.mat'}
    end
    
    methods
        function obj=SunLoader(filePath)
            obj.path=DataHandlers.checkPath(filePath);
            obj.objects=obj.getObjectCategories();
        end
        function out=getData(obj,desiredData)
            tmpPath=fullfile(obj.path,desiredData{2});
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath,desiredData{1});
            out=in.(desiredData{1});
        end
    end
    methods(Access='protected')
        function cat=getObjectCategories(obj)
            tmpPath=fullfile(obj.path,obj.catFileName);
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath);
            cat(length(in.names),1).name=in.names{end};
            for i=1:length(in.names)
                cat(i).name=in.names{i};
                cat(i).height=in.heights(i);
            end
        end
    end
    
end

