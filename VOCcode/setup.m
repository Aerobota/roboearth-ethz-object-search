%% Global definitions
global datasetPath
global originalPWD;
global imageLoader;

%% Parameters
detectorPath='ObjectDetector';
datasetPath='Dataset/NYU';
modelPath='Models';
removeTemporaries=true;


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
imageLoader=DataHandlers.NYUGTLoader(datasetFolder);
imageLoader.bufferDataset(imageLoader.trainSet,sprintf(VOCopts.imgsetpath,'trainval'));
classes={imageLoader.classes.name}';

[~,~,~]=copyfile(sprintf(VOCopts.imgsetpath,'trainval'),sprintf(VOCopts.imgsetpath,'train'));

%% Ready for detector
cd(detectorPath)