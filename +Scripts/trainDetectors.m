%% Parameters
@@@@@@@@@@@@@@@@@@@@@@@@ %not yet checked

detectorPath='ObjectDetector';
datasetPath='Dataset/NYU';
negativePath='Dataset/NYU';
modelPath='Models';
removeTemporaries=true;
nComponents=2;


%% Setup
addpath('VOCcode')
setup

%% Preprocessing
if removeTemporaries
    globals
    [~,~,~]=rmdir(cachedir,'s');
    [~,~,~]=rmdir(tmpdir,'s');
end

%remove already learned data from set
toCompute=true(size(classes));
for c=1:length(classes)
    if exist(fullfile(modelDestFolder,[classes{c} '.mat']),'file')
        toCompute(c)=false;
    elseif exist(fullfile(modelFolder,[classes{c} '.mat']),'file')
        toCompute(c)=false;
    end
end
classes=classes(toCompute);

%% Class learning
errorList=cell(length(classes),1);
% learn a detector for every class
for c=1:length(classes)
    try
        pascal_train(classes{c},nComponents);
        if ~exist(modelDestFolder,'dir')
            [~,~,~]=mkdir(modelDestFolder);
        end
        [~,~,~]=copyfile(fullfile(cachedir,[classes{c} '_final.mat']),...
            fullfile(modelDestFolder,[classes{c} '.mat']));
    catch e
        errorList{c}=e;
    end
end

%% Clean up
cd(originalPWD)

for c=1:length(classes)
    if ~isempty(errorList{c})
        disp(classes{c})
        rethrow(errorList{c})
    end
end