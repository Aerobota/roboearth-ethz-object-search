%% Parameters

datasetPath='Dataset/NYU';
% occurrenceStates={'0','1','2+'};
occurrenceStates={'0','1+'};
valueMatrix=[0 -1;-0.5 1];
% valueMatrix=[0 -0.5;-1 1];
% valueMatrix=[0 -1;-0.3 1];
% valueMatrix=[1 -1;-1 1];

%% Initialise

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train','gt');
dataTrain.load();

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test','gt');
dataTest.load();

classes=dataTrain.getClassNames;
classesSmall=classes([1 2 7 9 10 12 14 16 18 22 25 26 32 33 35 36 37 38 39]);

evidenceGenerator=LearnFunc.CooccurrenceEvidenceGenerator(occurrenceStates);

learner=LearnFunc.ConditionalOccurrenceLearner(evidenceGenerator,classesSmall,valueMatrix);

evaluatorOpt=Evaluation.CostOptimalOccurrenceEvaluator(evidenceGenerator);
evaluatorThresh=Evaluation.ThresholdOccurrenceEvaluator(evidenceGenerator);

%% Learn probabilities

dependencies=learner.learnStructure(dataTrain);

%% Evaluate Test Images

resultOpt=evaluatorOpt.evaluate(dataTest,dependencies);
resultThresh=evaluatorThresh.evaluate(dataTest,dependencies);

figure()
resultOpt.perClass.drawROC('receiver operating characteristic for optimal value');

figure()
resultThresh.cummulative.drawROC('receiver operating characteristic for optimal value');

figure()
resultOpt.perClass.drawPrecisionRecall('precision recall for optimal value');

figure()
resultThresh.cummulative.drawPrecisionRecall('precision recall for optimal value');
