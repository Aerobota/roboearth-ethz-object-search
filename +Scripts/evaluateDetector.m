%% Parameters

modelPath='Models/good';
datasetPath='Dataset/NYU';
threshold=-1.05;


%% Init
detector=DataHandlers.HOGDetector(threshold,fullfile(pwd,modelPath));
dataLoader=DataHandlers.NYUDetLoader(fullfile(pwd,datasetPath));
gtLoader=DataHandlers.NYUGTLoader(fullfile(pwd,datasetPath));

%% Extraction
dataLoader.extractDetections(gtLoader,detector);
