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

%% Generate graphs

[~,bestClasses]=sort(resultThresh.conditioned.expectedUtility,'descend');
[~,worstClasses]=sort(resultThresh.conditioned.expectedUtility,'ascend');
bestClasses=bestClasses(1:min(5,end));
worstClasses=worstClasses(1:min(5,end));
bestText=['best ' num2str(length(bestClasses)) ' classes'];
worstText=['worst ' num2str(length(bestClasses)) ' classes'];

roc=Evaluation.ROCEvaluationData;
roc.addData(resultThresh.conditioned,'informed')
roc.addData(resultThresh.conditioned,bestText,bestClasses)
roc.addData(resultThresh.conditioned,worstText,worstClasses)
roc.addData(resultThresh.baseline,'baseline')
roc.setTitle('receiver operating characteristic')
roc.draw()

precRecall=Evaluation.PrecRecallEvaluationData;
precRecall.addData(resultThresh.conditioned,'informed')
precRecall.addData(resultThresh.conditioned,bestText,bestClasses)
precRecall.addData(resultThresh.conditioned,worstText,worstClasses)
precRecall.addData(resultThresh.baseline,'baseline')
precRecall.setTitle('precision recall curve')
precRecall.draw()

costOpt=Evaluation.CostOptimalEvaluationData;
goodClasses=resultOpt.conditioned.tp~=0 & resultOpt.conditioned.fp~=0;
costOpt.addData(resultOpt.conditioned,'individual',goodClasses)
costOpt.setBaseline(resultOpt.baseline)
costOpt.draw()

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
