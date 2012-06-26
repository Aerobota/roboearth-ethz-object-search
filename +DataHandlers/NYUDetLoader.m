classdef NYUDetLoader<DataHandlers.NYULoader
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        trainSet={'Ddetectortraining' 'detectionsTrain.mat'}
        testSet={'Ddetectortest' 'detectionsTest.mat'}
    end
    
    methods
        function obj=NYUDetLoader(filePath)
            obj=obj@DataHandlers.NYULoader(filePath);
            if ~exist(fullfile(obj.path,obj.trainSet{2}),'file') ||...
                    ~exist(fullfile(obj.path,obj.testSet{2}),'file')
                warning('Detections are not extracted yet');
            end
        end
        function extractDetections(obj,groundTruthLoader,detector)
            Ddetectortraining=obj.runDetector(groundTruthLoader.getData(groundTruthLoader.trainSet),...
                {groundTruthLoader.classes.name},...
                fullfile(groundTruthLoader.path,groundTruthLoader.imageFolder),...
                detector);
            save(fullfile(obj.path,obj.trainSet{2}),obj.trainSet{1})
            clear(obj.trainSet{1})
            
            Ddetectortest=obj.runDetector(groundTruthLoader.getData(groundTruthLoader.testSet),...
                {groundTruthLoader.classes.name},...
                fullfile(groundTruthLoader.path,groundTruthLoader.imageFolder),...
                detector);
            save(fullfile(obj.path,obj.testSet{2}),obj.testSet{1})
            clear(obj.testSet{1})
        end
    end
    methods(Static,Access='protected')
        function data=runDetector(data,classes,imgPath,detector)
            for c=1:length(classes)
                for i=1:length(data)
                    data(i).annotation.object=[data(i).annotation.object,...
                        detector.detectClass(classes{c},...
                        imread(fullfile(imgPath,data(i).annotation.folder,data(i).annotation.filename)))];
                end
            end
        end
    end
end