%% Parameters

standardMaxDistance=2;
maxCandidates=10;

colours={[0 0.6 0],[1 0.6 0],[0.6 0 0.6],[1 0.4 0.7]}; %,[0.63 0.32 0.18]
styles={'-'};

goodClasses=[3 12];
badClasses=[8 10];

firstNPlotType='line';
firstNPlotStyle={':o'};

%% Initialise

assert(exist('resultCylindricGMM','var')==1 && exist('resultCylindricGaussian','var')==1,...
    'Scripts.computeLocationData needs to be run before this script.')

%% Plot distance comparison

gmmDistancesFROC=Evaluation.ROCEvaluationData;
gmmDistancesPrecRecall=Evaluation.PrecRecallEvaluationData;
gmmDistancesFirstN=Evaluation.FirstNEvaluationData(maxCandidates,firstNPlotType);

for i=1:length(resultCylindricGMM.FROC)
    gmmDistancesFROC.addData(resultCylindricGMM.FROC{i},['max distance = ' num2str(resultCylindricGMM.maxDistances(i)) ' m'],...
        colours{mod(i-1,length(colours))+1},styles{mod(i-1,length(styles))+1});
    gmmDistancesPrecRecall.addData(resultCylindricGMM.FROC{i},['max distance = ' num2str(resultCylindricGMM.maxDistances(i)) ' m'],...
        colours{mod(i-1,length(colours))+1},styles{mod(i-1,length(styles))+1});
    gmmDistancesFirstN.addData(resultCylindricGMM.FirstN{i},['max distance = ' num2str(resultCylindricGMM.maxDistances(i)) ' m'],...
        colours{mod(i-1,length(colours))+1},firstNPlotStyle{mod(i-1,length(firstNPlotStyle))+1});
end

%gmmDistancesFROC.setTitle('free-response receiver operating characteristic')
gmmDistancesPrecRecall.setTitle('precision-recall curve')
%gmmDistancesFirstN.setTitle('search task')

% gmmDistancesFROC.draw()
gmmDistancesPrecRecall.draw()
% gmmDistancesFirstN.draw()

%% Plot model comparison

modelCompFROC=Evaluation.ROCEvaluationData;
modelCompPrecRecall=Evaluation.PrecRecallEvaluationData;
modelCompFirstN=Evaluation.FirstNEvaluationData(maxCandidates,firstNPlotType);

i=resultCylindricGaussian.maxDistances==resultCylindricGMM.maxDistances(standardMaxDistance);

modelCompFROC.addData(resultCylindricGMM.FROC{standardMaxDistance},'mixture',...
    colours{mod(0,length(colours))+1},styles{mod(0,length(styles))+1});
modelCompFROC.addData(resultCylindricGaussian.FROC{i},'single',...
    colours{mod(1,length(colours))+1},styles{mod(1,length(styles))+1});

modelCompPrecRecall.addData(resultCylindricGMM.FROC{standardMaxDistance},'mixture',...
    colours{mod(0,length(colours))+1},styles{mod(0,length(styles))+1});
modelCompPrecRecall.addData(resultCylindricGaussian.FROC{i},'single',...
    colours{mod(1,length(colours))+1},styles{mod(1,length(styles))+1});

modelCompFirstN.addData(resultCylindricGMM.FirstN{standardMaxDistance},'mixture',...
    colours{mod(0,length(colours))+1},firstNPlotStyle{mod(0,length(firstNPlotStyle))+1});
modelCompFirstN.addData(resultCylindricGaussian.FirstN{i},'single',...
    colours{mod(1,length(colours))+1},firstNPlotStyle{mod(1,length(firstNPlotStyle))+1});

% modelCompFROC.setTitle({'free-response receiver operating characteristic',['max distance = ' num2str(resultCylindricGMM.maxDistances(standardMaxDistance)) ' m']})
% modelCompPrecRecall.setTitle({'precision recall curve',['max distance = ' num2str(resultCylindricGMM.maxDistances(standardMaxDistance)) ' m']})
% modelCompFirstN.setTitle({'search task',['max distance = ' num2str(resultCylindricGMM.maxDistances(standardMaxDistance)) ' m']})

modelCompFROC.setTitle('free-response receiver operating characteristic')
modelCompPrecRecall.setTitle('precision recall curve')
modelCompFirstN.setTitle('search task')

% modelCompFROC.draw()
% modelCompPrecRecall.draw()
% modelCompFirstN.draw()

%% Compare good and bad classes

% goodComp=Evaluation.FirstNEvaluationData;
% badComp=Evaluation.FirstNEvaluationData;
indiComp=Evaluation.FirstNEvaluationData(maxCandidates,firstNPlotType);

% goodComp.addData(resultCylindricGMM.FirstN{standardMaxDistance},'all classes',...
%     colours{mod(0,length(colours))+1},styles{mod(0,length(styles))+1});
% badComp.addData(resultCylindricGMM.FirstN{standardMaxDistance},'all classes',...
%     colours{mod(0,length(colours))+1},styles{mod(0,length(styles))+1});
indiComp.addData(resultCylindricGMM.FirstN{standardMaxDistance},'all classes',...
    colours{mod(0,length(colours))+1},firstNPlotStyle{mod(0,length(firstNPlotStyle))+1});

% for i=goodClasses
%     goodComp.addData(resultCylindricGMM.FirstN{standardMaxDistance},resultCylindricGMM.classes{i},...
%         colours{mod(i-1,length(colours))+1},firstNPlotStyle,i);
% end

% for i=badClasses
%     badComp.addData(resultCylindricGMM.FirstN{standardMaxDistance},resultCylindricGMM.classes{i},...
%         colours{mod(i-1,length(colours))+1},firstNPlotStyle,i);
% end


indiClasses=[goodClasses badClasses];
for i=1:numel(indiClasses)
    indiComp.addData(resultCylindricGMM.FirstN{standardMaxDistance},resultCylindricGMM.classes{indiClasses(i)},...
        colours{mod(i,length(colours))+1},firstNPlotStyle{mod(i,length(firstNPlotStyle))+1},indiClasses(i));
end

% goodComp.setTitle({'search task for good classes',['max distance = ' num2str(resultCylindricGMM.maxDistances(standardMaxDistance)) ' m']})
% badComp.setTitle({'search task for bad classes',['max distance = ' num2str(resultCylindricGMM.maxDistances(standardMaxDistance)) ' m']})

% goodComp.setTitle('search task for good classes')
% badComp.setTitle('search task for bad classes')
indiComp.setTitle('search task for individual classes')

%goodComp.draw(maxCandidates,firstNPlotType)
%badComp.draw(maxCandidates,firstNPlotType)
% indiComp.draw();

%% Clear temporaries

clear('i','colours','styles','standardMaxDistance','maxCandidates','goodClasses','badClasses','firstNPlotType')