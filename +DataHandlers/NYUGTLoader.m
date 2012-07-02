classdef NYUGTLoader<DataHandlers.NYULoader
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        trainSet='groundTruthTrain.mat'
        testSet='groundTruthTest.mat'
    end
    
    methods
        function obj=NYUGTLoader(filePath)
            obj=obj@DataHandlers.NYULoader(filePath);
        end
    end
end