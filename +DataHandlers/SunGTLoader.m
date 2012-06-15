classdef SunGTLoader<DataHandlers.SunLoader
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant)
%         catFileName='sun09_objectCategories.mat';
        trainSet={'Dtraining' 'sun09_groundTruth.mat'}
        testSet={'Dtest' 'sun09_groundTruth.mat'}
    end
    
    methods
        function obj=SunGTLoader(filePath)
            obj=obj@DataHandlers.SunLoader(filePath);
        end
    end
end