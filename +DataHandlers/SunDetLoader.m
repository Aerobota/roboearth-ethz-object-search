classdef SunDetLoader<DataHandlers.SunLoader
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        trainSet={'DdetectorTraining' 'sun09_detectorOutputs.mat'};
        testSet={'DdetectorTest' 'sun09_detectorOutputs.mat'}
    end
    
    methods
        function obj=SunDetLoader(filePath)
            obj=obj@DataHandlers.SunLoader(filePath);
        end
    end
end