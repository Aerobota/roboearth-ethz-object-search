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
        function extractDetections(obj,groundTruthLoader,detector,dataset)
            doTrain=false;
            doTest=false;
            if nargin<4
                doTrain=true;
                doTest=true;
            else
                if all(strcmp(dataset,obj.trainSet))
                    doTrain=true;
                elseif all(strcmp(dataset,obj.testSet))
                    doTest=true;
                end
            end
               
            if doTrain
                Ddetectortraining=obj.runDetector(groundTruthLoader.getData(groundTruthLoader.trainSet),...
                    {groundTruthLoader.classes.name},...
                    fullfile(groundTruthLoader.path,groundTruthLoader.imageFolder),...
                    detector);
                save(fullfile(obj.path,obj.trainSet{2}),obj.trainSet{1})
                clear(obj.trainSet{1})
            end
            
            if doTest
                Ddetectortest=obj.runDetector(groundTruthLoader.getData(groundTruthLoader.testSet),...
                    {groundTruthLoader.classes.name},...
                    fullfile(groundTruthLoader.path,groundTruthLoader.imageFolder),...
                    detector);
                save(fullfile(obj.path,obj.testSet{2}),obj.testSet{1})
                clear(obj.testSet{1})
            end
        end
    end
    methods(Static,Access='protected')
        function data=runDetector(data,classes,imgPath,detector)
            nData=length(data);
            parfor i=1:nData
                %if mod(i,round(nData/10))==0
                    disp(['detecting image ' num2str(i) '/' num2str(nData)])
                %end
                data(i).annotation.object=[];
                for c=1:length(classes)
                    data(i).annotation.object=[data(i).annotation.object,...
                        detector.detectClass(classes{c},...
                        imread(fullfile(imgPath,data(i).annotation.folder,data(i).annotation.filename)))];
                end
            end
        end
    end
end