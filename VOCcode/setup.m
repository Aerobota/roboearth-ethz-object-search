detectorPath='ObjectDetector';
global datasetPath
datasetPath='Dataset/NYU';

global originalPWD;
originalPWD=pwd;

addpath(originalPWD);

VOCinit


removeTemporaries=true;
% global datasetPath;
% datasetPath=fullfile(pwd,'Dataset/DummySet');


% if datasetPath(end)~=filesep
%     datasetPath=[datasetPath filesep];
% end
% lowLevelLoaders={DataHandlers.SunGTLoader(fullfile(pwd,'../Sun09/dataset'));...
%     DataHandlers.GroundTruthLoader(fullfile(pwd,'Dataset/DummySet'))};
%lowLevelLoaders={DataHandlers.SunGTLoader(fullfile(pwd,'Dataset/NYU_clean'))};
global imageLoader;
imageLoader=DataHandlers.NYUGTLoader(fullfile(pwd,'Dataset/NYU'));
imageLoader.bufferDataset(imageLoader.trainSet,sprintf(VOCopts.imgsetpath,'trainval'));

%imageLoader=CombinedDataLoader(lowLevelLoaders,sprintf(VOCopts.imgsetpath,'trainval'));
[~,~,~]=copyfile(sprintf(VOCopts.imgsetpath,'trainval'),sprintf(VOCopts.imgsetpath,'train'));
%imageLoader.generateNameList({'train.txt','trainval.txt'});

addpath(fullfile(originalPWD,detectorPath));
cd(detectorPath)
cd

%list of the classes to be learned
% classes={'screen';'keyboard';'mouse';'window';'door';'table';'chair'};
classes={imageLoader.classes.name}';
%classes={'table'};