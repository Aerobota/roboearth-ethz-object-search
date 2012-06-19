addpath('VOCcode')
setup
errorList=cell(length(classes),1);
% learn a detector for every class
for c=1:length(classes)
    try
        pascal_train(classes{c},1);
    catch e
        errorList{c}=e;
    end
end

cd(originalPWD)

if removeTemporaries
    globals
    [~,~,~]=rmdir(cachedir,'s');
    [~,~,~]=rmdir(tmpdir,'s');
end



for c=1:length(classes)
    if ~isempty(errorList{c})
        disp(classes{c})
        rethrow(errorList{c})
    end
end
