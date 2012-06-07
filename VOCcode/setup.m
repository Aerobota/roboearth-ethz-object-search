detectorPath='ObjectDetector';

global originalPWD;
originalPWD=pwd;

addpath(originalPWD);

global datasetPath;
datasetPath=[pwd filesep 'Dataset/DummySet'];


if datasetPath(end)~=filesep
    datasetPath=[datasetPath filesep];
end
global imageLoader;
imageLoader=DataHandlers.GroundTruthLoader(datasetPath);
imageLoader.generateNameList({'train.txt','trainval.txt'});

cd(detectorPath)

%list of the classes to be learned
classes={'screen';'keyboard';'mouse';'window';'door';'table';'chair'};