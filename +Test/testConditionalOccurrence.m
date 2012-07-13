%% Parameters

datasetPath='Dataset/NYU';
occurrenceStates={'0','1','2+'};
maxParents=10; % if maxParents is set too large the conditional probabilities can consume a lot of memory
% nrThresholds=500;
valueMatrix=[0 -1;-0.5 1];
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

% precisionTPR=linspace(0,1,200);
% precisionFPR=precisionTPR*(resultOpt.cummulative.positives/resultOpt.cummulative.negatives);
% 
% figure()
% plot(resultOpt.perClass.fpRate,resultOpt.perClass.tpRate,'b*',...
%     resultOpt.cummulative.fpRate,resultOpt.cummulative.tpRate,'r*',...
%     resultOpt.baseline.fpRate,resultOpt.baseline.tpRate,'g-',...
%     precisionFPR,precisionTPR,'k--')
% 
% axis([0 1 0 1])
% legend('separate','summed','baseline','precision=0.5','location','southeast')
% xlabel('false positive rate')
% ylabel('true positive rate')
% title('receiver operating characteristic for optimal value')
% 
% hold on
% text(resultOpt.perClass.fpRate+0.01,resultOpt.perClass.tpRate-0.01,resultOpt.perClass.names,'color','b')
% 
% figure()
% plot(resultThresh.cummulative.fpRate,resultThresh.cummulative.tpRate,'r-',...
%     resultThresh.baseline.fpRate,resultThresh.baseline.tpRate,'g-',...
%     precisionFPR,precisionTPR,'k--')
% 
% axis([0 1 0 1])
% legend('summed','baseline','precision=0.5','location','southeast')
% xlabel('false positive rate')
% ylabel('true positive rate')
% title('receiver operating characteristic for varying thresholds')
% 
% figure()
% plot(resultOpt.perClass.tpRate,resultOpt.perClass.precision,'b*',...
%     resultThresh.baseline.tpRate,resultThresh.baseline.precision,'g-')
% 
% axis([0 1 0 1])
% legend('separate','baseline','location','southeast')
% xlabel('recall')
% ylabel('precision')
% title('precision recall for optimal value')
% 
% hold on
% text(resultOpt.perClass.tpRate+0.01,resultOpt.perClass.precision-0.01,resultOpt.perClass.names,'color','b')
% 
% figure()
% plot(resultThresh.cummulative.tpRate,resultThresh.cummulative.precision,'r-',...
%     resultThresh.baseline.tpRate,resultThresh.baseline.precision,'g-')
% 
% axis([0 1 0 1])
% legend('summed','baseline','location','southeast')
% xlabel('recall')
% ylabel('precision')
% title('precision recall for varying thresholds')

% figure()
% plot(resultOpt.perClass.fp,resultOpt.perClass.tp,'b*',...
%     resultOpt.cummulative.fp,resultOpt.cummulative.tp,'r*',...
%     resultOpt.baseline.fp,resultOpt.baseline.tp,'g-',...
%     [0 1],[0 1],'k--')
% 
% legend('separate','summed','baseline','precision=0.5','location','southeast')
% xlabel('false positives')
% ylabel('true positives')
% title('receiver operating characteristic for optimal cost')
% 
% hold on
% text(resultOpt.perClass.fp+0.01,resultOpt.perClass.tp-0.01,resultOpt.perClass.names,'color','b')
% 
% figure()
% plot(resultThresh.cummulative.fp,resultThresh.cummulative.tp,'r-',...
%     resultThresh.baseline.fp,resultThresh.baseline.tp,'g-',...
%     [0 1],[0 1],'k--')
% 
% legend('summed','baseline','precision=0.5','location','southeast')
% xlabel('false positives')
% ylabel('true positives')
% title('receiver operating characteristic for varying thresholds')

% hold on
% text(resultThresh.perClass.fpRate+0.01,resultThresh.perClass.tpRate-0.01,resultThresh.perClass.names,'color','b')

