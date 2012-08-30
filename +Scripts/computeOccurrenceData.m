%% Parameters

occurrenceStates{1}={'0','1+'};
occurrenceStates{2}={'0','1','2+'};
valueMatrix{1}=[1 -1;-1 1];
valueMatrix{2}=[0 -1;-0.5 1];
% valueMatrix{3}=[0 -0.5;-1 1];
% valueMatrix{4}=[0 -1;-0.3 1];

%% Initialise

disp('initialising')

Scripts.setPaths

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train');

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test');

for o=length(occurrenceStates):-1:1
    occEvidenceGenerator{o,2}=LearnFunc.NaiveOccurrenceEvidenceGenerator(occurrenceStates{o});
    occEvidenceGenerator{o,1}=LearnFunc.ConditionalOccurrenceEvidenceGenerator(occurrenceStates{o});
end

for o=length(occEvidenceGenerator):-1:1
    for p=size(occEvidenceGenerator,2):-1:1
        for m=length(valueMatrix):-1:1
            occLearner{m,o,p}=LearnFunc.ExpectedUtilityOccurrenceLearner(occEvidenceGenerator{o,p},valueMatrix{m});
        end
    end
    occNaiveLearner{o}=LearnFunc.NaiveOccurrenceLearner(occEvidenceGenerator{o,2});
end

evaluatorThresh=Evaluation.ThresholdOccurrenceEvaluator();

%% Load data

disp('loading data')

dataTrain.load();
dataTest.load();

%% Learn probabilities

disp('learning')

for l=1:numel(occLearner)
    occLearner{l}.learn(dataTrain);
end

for l=1:numel(occNaiveLearner)
    occNaiveLearner{l}.learn(dataTrain);
end

%% Evaluate Test Images

disp('evaluating')

resultThresh=cell(size(occLearner));

for l=1:numel(occLearner)
    resultThresh{l}=evaluatorThresh.evaluate(dataTest,occLearner{l});
end

resultThreshNaive=cell(size(occNaiveLearner));

for l=1:numel(occNaiveLearner)
    resultThreshNaive{l}=evaluatorThresh.evaluate(dataTest,occNaiveLearner{l});
end

%% Clear temporaries

clear('l','m','o','dataTrain','dataTest','occEvidenceGenerator',...
    'evaluatorThresh','sourceFolder','datasetPath')

%% Save results to file

save('tmpOccurrenceData.mat','occurrenceStates','valueMatrix','occLearner',...
    'occNaiveLearner','resultThresh','resultThreshNaive')
