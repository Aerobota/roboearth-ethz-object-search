%% Parameters

datasetPath='Dataset/NYU';
occurrenceStates={'0','1','2+'};
maxParents=10; % if maxParents is set too large the conditional probabilities will consume a lot of memory
valueMatrix=[0 -1;-0.5 1];
% valueMatrix=[1 -1;-1 1];
% valueMatrix=[0 0;-1 1];

%% Initialise

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train','gt');
dataTrain.load();

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test','gt');
dataTest.load();

classes=dataTrain.getClassNames;
classesSmall=classes([1 2 7 9 10 12 14 16 18 22 25 26 32 33 35 36 37 38 39]);

evidenceGenerator=LearnFunc.CooccurrenceEvidenceGenerator(occurrenceStates);

learner=LearnFunc.ConditionalOccurrenceLearner(evidenceGenerator,classesSmall,valueMatrix);

evaluator=Evaluation.CostOptimalOccurrenceEvaluator(evidenceGenerator);

%% Learn probabilities

dependencies=learner.learnStructure(dataTrain);

%% Evaluate Test Images

result=evaluator.evaluateROC(dataTest,dependencies);

figure()
plot(result.perClass.fpRate,result.perClass.tpRate,'b*',...
result.cummulative.fpRate,result.cummulative.tpRate,'r*',...
[0 1],[0 1],'k--')

legend('separate','summed','precision=0.5','location','southeast')
xlabel('false positive rate')
ylabel('true positive rate')
title('receiver operating characteristic')

hold on
text(result.perClass.fpRate,result.perClass.tpRate,result.perClass.names,'color','b')

