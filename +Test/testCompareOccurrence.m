%% Parameters

datasetPath='Dataset/NYU';
% occurrenceStates={'0','1','2+'};
occurrenceStates={'0','1+'};
valueMatrix=[0 -1;-0.5 1];
% valueMatrix=[0 -0.5;-1 1];
% valueMatrix=[0 -1;-0.3 1];
% valueMatrix=[1 -1;-1 1];

colours={'k','b',[0 0.6 0],[0.8 0 0]}; %{baseline,informed,good,bad}
styles={'-','-.','--','--'};

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

evaluatorThresh=Evaluation.ThresholdOccurrenceEvaluator();

%% Learn probabilities

learnerCond.learn(dataTrain);
learnerCondSimple.learn(dataTrain);
learnerNaive.learn(dataTrain);

%% Evaluate Test Images

resultThreshCond=evaluatorThresh.evaluate(dataTest,learnerCond);
resultThreshCondSimple=evaluatorThresh.evaluate(dataTest,learnerCondSimple);
resultThreshNaive=evaluatorThresh.evaluate(dataTest,learnerNaive);

%% Generate graphs

[~,bestClasses]=sort(resultThreshCond.conditioned.expectedUtility,'descend');
[~,worstClasses]=sort(resultThreshCond.conditioned.expectedUtility,'ascend');
bestClasses=bestClasses(1:min(5,end));
worstClasses=worstClasses(1:min(5,end));
bestText=['best ' num2str(length(bestClasses)) ' classes'];
worstText=['worst ' num2str(length(bestClasses)) ' classes'];

precRecallAll=Evaluation.PrecRecallEvaluationData;
precRecallAll.addData(resultThreshCond.conditioned,'informed',colours{2},styles{2})
precRecallAll.addData(resultThreshCondSimple.conditioned,'simple',colours{3},styles{3})
% precRecall.addData(resultThresh.conditioned,bestText,colours{3},styles{3},bestClasses)
precRecallAll.addData(resultThreshNaive.conditioned,'naive',colours{4},styles{4})
precRecallAll.addData(resultThreshCond.baseline,'baseline',colours{1},styles{1})
precRecallAll.setTitle('precision recall curve')
precRecallAll.draw()

precRecallBest=Evaluation.PrecRecallEvaluationData;
precRecallBest.addData(resultThreshCond.conditioned,'informed',colours{2},styles{2},bestClasses)
precRecallBest.addData(resultThreshCondSimple.conditioned,'simple',colours{3},styles{3},bestClasses)
% precRecall.addData(resultThresh.conditioned,bestText,colours{3},styles{3},bestClasses)
precRecallBest.addData(resultThreshNaive.conditioned,'naive',colours{4},styles{4},bestClasses)
precRecallBest.addData(resultThreshCond.baseline,'baseline',colours{1},styles{1},bestClasses)
precRecallBest.setTitle('precision recall curve for 5 best classes')
precRecallBest.draw()

precRecallWorst=Evaluation.PrecRecallEvaluationData;
precRecallWorst.addData(resultThreshCond.conditioned,'informed',colours{2},styles{2},worstClasses)
precRecallWorst.addData(resultThreshCondSimple.conditioned,'simple',colours{3},styles{3},worstClasses)
% precRecall.addData(resultThresh.conditioned,bestText,colours{3},styles{3},bestClasses)
precRecallWorst.addData(resultThreshNaive.conditioned,'naive',colours{4},styles{4},worstClasses)
precRecallWorst.addData(resultThreshCond.baseline,'baseline',colours{1},styles{1},worstClasses)
precRecallWorst.setTitle('precision recall curve for 5 worst classes')
precRecallWorst.draw()