%% Parameters

datasetPath='Dataset/NYU';
% occurrenceStates={'0','1','2+'};
occurrenceStates={'0','1+'};
valueMatrix=[0 -1;-0.5 1];
% valueMatrix=[0 -0.5;-1 1];
% valueMatrix=[0 -1;-0.3 1];
% valueMatrix=[1 -1;-1 1];

colours={'k','b',[0 0.6 0],[0.8 0 0],[0.3 0.3 0]}; %{baseline,informed,good,bad}
styles={'-','-.','--','--','--'};

%% Initialise

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train');
dataTrain.load();

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test');
dataTest.load();

evidenceGeneratorCond=LearnFunc.ConditionalOccurrenceEvidenceGenerator(occurrenceStates);
evidenceGeneratorNaive=LearnFunc.NaiveOccurrenceEvidenceGenerator(occurrenceStates);

learnerCond=LearnFunc.ExpectedUtilityOccurrenceLearner(evidenceGeneratorCond,valueMatrix);
learnerCondSimple=LearnFunc.ExpectedUtilityOccurrenceLearner(evidenceGeneratorCond,valueMatrix,1);
learnerNaive=LearnFunc.NaiveOccurrenceLearner(evidenceGeneratorNaive);
learnerNaiveReduced=LearnFunc.ExpectedUtilityOccurrenceLearner(evidenceGeneratorNaive,valueMatrix);

evaluatorThresh=Evaluation.ThresholdOccurrenceEvaluator();

%% Learn probabilities

learnerCond.learn(dataTrain);
learnerCondSimple.learn(dataTrain);
learnerNaive.learn(dataTrain);
learnerNaiveReduced.learn(dataTrain);

%% Evaluate Test Images

resultThreshCond=evaluatorThresh.evaluate(dataTest,learnerCond);
resultThreshCondSimple=evaluatorThresh.evaluate(dataTest,learnerCondSimple);
resultThreshNaive=evaluatorThresh.evaluate(dataTest,learnerNaive);
resultThreshNaiveReduced=evaluatorThresh.evaluate(dataTest,learnerNaiveReduced);

%% Generate graphs

precRecallAll=Evaluation.PrecRecallEvaluationData;
precRecallAll.addData(resultThreshCond.conditioned,'informed',colours{2},styles{2})
precRecallAll.addData(resultThreshCondSimple.conditioned,'simple',colours{3},styles{3})
precRecallAll.addData(resultThreshNaive.conditioned,'naive',colours{4},styles{4})
precRecallAll.addData(resultThreshNaiveReduced.conditioned,'naive reduced',colours{5},styles{5})
precRecallAll.addData(resultThreshCond.baseline,'baseline',colours{1},styles{1})
precRecallAll.setTitle('precision recall curve')
precRecallAll.draw()