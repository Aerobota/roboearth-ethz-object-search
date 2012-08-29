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

evidenceGenerator=LearnFunc.ConditionalOccurrenceEvidenceGenerator(occurrenceStates);

learner=LearnFunc.ExpectedUtilityOccurrenceLearner(evidenceGenerator,valueMatrix);

evaluatorThresh=Evaluation.ThresholdOccurrenceEvaluator();

%% Learn probabilities

learner.learn(dataTrain);

%% Evaluate Test Images

resultThresh=evaluatorThresh.evaluate(dataTest,learner);

%% Generate graphs

[~,bestClasses]=sort(resultThresh.conditioned.expectedUtility,'descend');
[~,worstClasses]=sort(resultThresh.conditioned.expectedUtility,'ascend');
bestClasses=bestClasses(1:min(5,end));
worstClasses=worstClasses(1:min(5,end));
bestText=['best ' num2str(length(bestClasses)) ' classes'];
worstText=['worst ' num2str(length(bestClasses)) ' classes'];

precRecall=Evaluation.PrecRecallEvaluationData;
precRecall.addData(resultThresh.conditioned,'informed',colours{2},styles{2})
precRecall.addData(resultThresh.conditioned,bestText,colours{3},styles{3},bestClasses)
precRecall.addData(resultThresh.conditioned,worstText,colours{4},styles{4},worstClasses)
precRecall.addData(resultThresh.baseline,'baseline',colours{1},styles{1})
precRecall.setTitle('precision recall curve')
precRecall.draw()