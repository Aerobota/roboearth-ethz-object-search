%% Parameters

occurrenceStates{1}={'0','1+'};
occurrenceStates{2}={'0','1','2+'};
valueMatrix{1}=[1 -1;-1 1];
valueMatrix{2}=[0 -1;-0.5 1];
valueMatrix{3}=[0 -0.5;-1 1];
valueMatrix{4}=[0 -1;-0.3 1];

%% Initialise

disp('initialising')

Scripts.setPaths

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train');

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test');

for o=length(occurrenceStates):-1:1
    occEvidenceGenerator{o}=LearnFunc.CooccurrenceEvidenceGenerator(occurrenceStates{o});
end

for o=length(occEvidenceGenerator):-1:1
    for m=length(valueMatrix):-1:1
        occLearner{m,o}=LearnFunc.ConditionalOccurrenceLearner(occEvidenceGenerator{o},valueMatrix{m});
    end
end

evaluatorOpt=Evaluation.CostOptimalOccurrenceEvaluator();
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

%% Evaluate Test Images

disp('evaluating')

resultOpt=cell(size(occLearner,1),size(occLearner,2));
resultThresh=cell(size(occLearner,1),size(occLearner,2));

for l=1:numel(occLearner)
    resultOpt{l}=evaluatorOpt.evaluate(dataTest,occLearner{l});
    resultThresh{l}=evaluatorThresh.evaluate(dataTest,occLearner{l});
end