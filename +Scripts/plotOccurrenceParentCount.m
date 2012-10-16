%% Initialise

assert(exist('resultThresh','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Parameters

desiredLearner=[2 1 1];

allParents=26;

%% Compute average

classNames=fieldnames(occLearner{desiredLearner(1),desiredLearner(2),desiredLearner(3)}.model);

for i=length(classNames):-1:1
    counts(i)=length(occLearner{desiredLearner(1),desiredLearner(2),desiredLearner(3)}.model...
        .(classNames{i}).parents);
end

figure()
bar([mean(counts) allParents])

ylabel('average number of parents')
axis([0.5 2.5 0 allParents+2])
set(gca,'XTickLabel',{'informed','naive'})