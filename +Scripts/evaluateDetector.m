%% Parameters

modelPath='Models/falseNames';
datasetPath='Dataset/NYU_falseNames';
threshold=-1.05;


%% Init
detector=DataHandlers.HOGDetector(threshold,fullfile(pwd,modelPath));
dataLoader=DataHandlers.NYUDetLoader(fullfile(pwd,datasetPath));
gtLoader=DataHandlers.NYUGTLoader(fullfile(pwd,datasetPath));

%dataLoader.extractDetections(gtLoader,detector);
dataLoader.extractDetections(gtLoader,detector,dataLoader.testSet);