%% Parameters

modelPath='Models/good';
datasetPath='Dataset/NYU';
threshold=-1.02;


%% Init
detector=DataHandlers.HOGDetector(threshold,fullfile(pwd,modelPath));

%% Extraction
disp('extracting training set')
gtData=DataHandlers.NYUDataStructure(datasetPath,DataHandlers.NYUDataStructure.trainSet,...
    DataHandlers.NYUDataStructure.gt);
gtData.load();
DataHandlers.extractDetections(gtData,detector);

disp('extracting test set')
gtData=DataHandlers.NYUDataStructure(datasetPath,DataHandlers.NYUDataStructure.testSet,...
    DataHandlers.NYUDataStructure.gt);
gtData.load();
DataHandlers.extractDetections(gtData,detector);
