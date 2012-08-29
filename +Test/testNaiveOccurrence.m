%% Parameters

datasetPath='Dataset/NYU';
% occurrenceStates={'0','1','2+'};
occurrenceStates={'0','1+'};

colours={'k','b',[0 0.6 0],[0.8 0 0]}; %{baseline,informed,good,bad}
styles={'-','-.','--','--'};

%% Initialise

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train');
dataTrain.load();

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test');
dataTest.load();

evidenceGenerator=LearnFunc.NaiveOccurrenceEvidenceGenerator(occurrenceStates);

learner=LearnFunc.NaiveOccurrenceLearner(evidenceGenerator);

evaluatorThresh=Evaluation.ThresholdOccurrenceEvaluator();

%% Learn probabilities

learner.learn(dataTrain);

%% Evaluate Test Images

resultThresh=evaluatorThresh.evaluate(dataTest,learner);

%% Generate graphs

precRecall=Evaluation.PrecRecallEvaluationData;
precRecall.addData(resultThresh.conditioned,'informed',colours{2},styles{2})
precRecall.addData(resultThresh.baseline,'baseline',colours{1},styles{1})
precRecall.setTitle('precision recall curve')
precRecall.draw()