%% Global definitions
global datasetFolder
global originalPWD;
global imageData;

%% Path generating
originalPWD=pwd;
modelDestFolder=fullfile(originalPWD,modelPath,'New');
modelFolder=fullfile(originalPWD,modelPath);
datasetFolder=fullfile(originalPWD,datasetPath);

addpath(originalPWD);
addpath(fullfile(originalPWD,detectorPath));

%% Initialisation
VOCinit

%% Data loading
imageData=DataHandlers.NYUDataStructure(datasetFolder,DataHandlers.NYUDataStructure.trainSet,DataHandlers.NYUDataStructure.gt);
imageData.load();
imageData.writeNameListFile(sprintf(VOCopts.imgsetpath,'trainval'));
negImgData=DataHandlers.SunDataStructure(datasetFolder,DataHandlers.SunDataStructure.trainSet,DataHandlers.SunDataStructure.gt);
negImgData.load();

imageData.addData(negImgData);
imageData.writeNameListFile(sprintf(VOCopts.imgsetpath,'train'));

classes=imageData.getClassNames();

%% Ready for detector
cd(detectorPath)