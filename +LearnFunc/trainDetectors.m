addpath('VOCcode')
setup

if removeTemporaries
    globals
    [~,~,~]=rmdir(cachedir,'s');
    [~,~,~]=rmdir(tmpdir,'s');
end

errorList=cell(length(classes),1);
% learn a detector for every class
for c=1:length(classes)
    try
        pascal_train(classes{c},1);
        destFolder=fullfile(originalPWD,'Models','New');
        if ~exist(destFolder,'dir')
            [~,~,~]=mkdir(destFolder);
        end
        [~,~,~]=copyfile(fullfile(cachedir,[classes{c} '_final.mat']),...
            fullfile(destFolder,[classes{c} '.mat']));
    catch e
        errorList{c}=e;
    end
end

cd(originalPWD)



for c=1:length(classes)
    if ~isempty(errorList{c})
        %disp(classes{c})
        rethrow(errorList{c})
    end
end