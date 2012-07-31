%% Parameters

datasetPath='Dataset/NYU';
% occurrenceStates={'0','1','2+'};
occurrenceStates={'0','1+'};
valueMatrix=[0 -1;-0.5 1];
% valueMatrix=[0 -0.5;-1 1];
% valueMatrix=[0 -1;-0.3 1];
% valueMatrix=[1 -1;-1 1];

%% Initialise

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train');
dataTrain.load();

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test');
dataTest.load();

classes=dataTrain.getClassNames;

evidenceGenerator=LearnFunc.CooccurrenceEvidenceGenerator(occurrenceStates);

learner=LearnFunc.ConditionalOccurrenceLearner(evidenceGenerator,valueMatrix);

evaluatorOpt=Evaluation.CostOptimalOccurrenceEvaluator();
evaluatorThresh=Evaluation.ThresholdOccurrenceEvaluator();

%% Learn probabilities

learner.learn(dataTrain);

%% Evaluate Test Images

resultOpt=evaluatorOpt.evaluate(dataTest,learner);
resultThresh=evaluatorThresh.evaluate(dataTest,learner);

roc=Evaluation.ROCEvaluationData;
roc.addData(resultThresh.conditioned,'informed')
roc.addData(resultThresh.baseline,'baseline')
roc.setTitle('receiver operating characteristic')
roc.draw()

precRecall=Evaluation.PrecRecallEvaluationData;
precRecall.addData(resultThresh.conditioned,'informed')
precRecall.addData(resultThresh.baseline,'baseline')
precRecall.setTitle('precision recall curve')
precRecall.draw()

% figure()
% resultOpt.perClass.drawROC('receiver operating characteristic for optimal value');
% 
% figure()
% resultThresh.cummulative.drawROC('receiver operating characteristic for optimal value');
% 
% figure()
% resultOpt.perClass.drawPrecisionRecall('precision recall for optimal value');
% 
% figure()
% resultThresh.cummulative.drawPrecisionRecall('precision recall for optimal value');
