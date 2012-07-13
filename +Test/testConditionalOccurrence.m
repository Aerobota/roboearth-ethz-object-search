%% Parameters

datasetPath='Dataset/NYU';
occurrenceStates={'0','1','2+'};
maxParents=10; % if maxParents is set too large the conditional probabilities can consume a lot of memory
nrThresholds=500;
valueMatrix=[0 -1;0 1];
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
evaluatorThresh=Evaluation.ThresholdOccurrenceEvaluator(evidenceGenerator,nrThresholds);

%% Learn probabilities

dependencies=learner.learnStructure(dataTrain);

%% Evaluate Test Images

resultOpt=evaluatorOpt.evaluateROC(dataTest,dependencies);
resultThresh=evaluatorThresh.evaluateROC(dataTest,dependencies);

figure()
plot(resultOpt.perClass.fpRate,resultOpt.perClass.tpRate,'b*',...
resultOpt.cummulative.fpRate,resultOpt.cummulative.tpRate,'r*',...
[0 1],[0 1],'k--')

legend('separate','summed','precision=0.5','location','southeast')
xlabel('false positive rate')
ylabel('true positive rate')
title('receiver operating characteristic for optimal cost')

hold on
text(resultOpt.perClass.fpRate+0.01,resultOpt.perClass.tpRate-0.01,resultOpt.perClass.names,'color','b')

figure()
plot(resultThresh.cummulative.fpRate,resultThresh.cummulative.tpRate,'r-',...
[0 1],[0 1],'k--')

legend('summed','precision=0.5','location','southeast')
xlabel('false positive rate')
ylabel('true positive rate')
title('receiver operating characteristic for varying thresholds')

% hold on
% text(resultThresh.perClass.fpRate+0.01,resultThresh.perClass.tpRate-0.01,resultThresh.perClass.names,'color','b')

