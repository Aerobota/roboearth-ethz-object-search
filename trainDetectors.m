setup

% learn a detector for every class
for c=1:length(classes)
    pascal_train(classes{c},1);
end

cd(originalPWD)