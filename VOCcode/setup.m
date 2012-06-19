detectorPath='ObjectDetector';

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
lowLevelLoaders={DataHandlers.SunGTLoader(fullfile(pwd,'../Sun09/dataset'));...
    DataHandlers.GroundTruthLoader(fullfile(pwd,'Dataset/DummySet'))};
global imageLoader;
imageLoader=CombinedDataLoader(lowLevelLoaders,sprintf(VOCopts.imgsetpath,'trainval'));
[~,~,~]=copyfile(sprintf(VOCopts.imgsetpath,'trainval'),sprintf(VOCopts.imgsetpath,'train'));
%imageLoader.generateNameList({'train.txt','trainval.txt'});

cd(detectorPath)

%list of the classes to be learned
% classes={'screen';'keyboard';'mouse';'window';'door';'table';'chair'};
classes={'table'};