%% Global definitions
global datasetPath
global originalPWD;
global imageLoader;

%% Parameters
detectorPath='ObjectDetector';
datasetPath='Dataset/NYU';
negativePath='Dataset/sun_negative';
modelPath='Models';
removeTemporaries=true;


%% Path generating
originalPWD=pwd;
modelDestFolder=fullfile(originalPWD,modelPath,'New');
modelFolder=fullfile(originalPWD,modelPath);
datasetFolder=fullfile(originalPWD,datasetPath);
negativeSamplesFolder=fullfile(originalPWD,negativePath);

addpath(originalPWD);
addpath(fullfile(originalPWD,detectorPath));

%% Initialisation
VOCinit

%% Data loading
imageLoader=DataHandlers.NYUGTLoader(datasetFolder);
imageLoader.bufferDataset(imageLoader.trainSet);
imageLoader.writeNameListFile(sprintf(VOCopts.imgsetpath,'trainval'));
negImageLoader=DataHandlers.SunGTLoader(negativeSamplesFolder);
imageLoader.addData(negImageLoader.getData(negImageLoader.trainSet));
imageLoader.writeNameListFile(sprintf(VOCopts.imgsetpath,'train'));

classes={imageLoader.classes.name}';

%% Ready for detector
cd(detectorPath)