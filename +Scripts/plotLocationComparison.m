%% Parameters

standardMaxDistance=2;
maxCandidates=10;

colours={'b','g','r','k'};
styles={'-','-.','--',':'};


%% Initialise

assert(exist('resultCylindricGMM','var')==1 && exist('resultCylindricGaussian','var')==1,...
    'Scripts.computeLocationData needs to be run before this script.')

%% Plot distance comparison

gmmDistancesFROC=Evaluation.ROCEvaluationData;
gmmDistancesPrecRecall=Evaluation.PrecRecallEvaluationData;
gmmDistancesFirstN=Evaluation.FirstNEvaluationData;

for i=1:length(resultCylindricGMM.FROC)
    gmmDistancesFROC.addData(resultCylindricGMM.FROC{i},['max distance = ' num2str(resultCylindricGMM.maxDistances(i)) ' m'],...
        colours{mod(i-1,length(colours))+1},styles{mod(i-1,length(styles))+1});
    gmmDistancesPrecRecall.addData(resultCylindricGMM.FROC{i},['max distance = ' num2str(resultCylindricGMM.maxDistances(i)) ' m'],...
        colours{mod(i-1,length(colours))+1},styles{mod(i-1,length(styles))+1});
    gmmDistancesFirstN.addData(resultCylindricGMM.FirstN{i},['max distance = ' num2str(resultCylindricGMM.maxDistances(i)) ' m'],...
        colours{mod(i-1,length(colours))+1},styles{mod(i-1,length(styles))+1});
end

gmmDistancesFROC.setTitle('free-response receiver operating characteristic')
gmmDistancesPrecRecall.setTitle('precision recall curve')
gmmDistancesFirstN.setTitle('search task')

gmmDistancesFROC.draw()
gmmDistancesPrecRecall.draw()
gmmDistancesFirstN.draw(maxCandidates)

%% Plot model comparison

modelCompFROC=Evaluation.ROCEvaluationData;
modelCompPrecRecall=Evaluation.PrecRecallEvaluationData;
modelCompFirstN=Evaluation.FirstNEvaluationData;

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
    colours{mod(0,length(colours))+1},styles{mod(0,length(styles))+1});
modelCompFirstN.addData(resultCylindricGaussian.FirstN{i},'single',...
    colours{mod(1,length(colours))+1},styles{mod(1,length(styles))+1});

modelCompFROC.setTitle({'free-response receiver operating characteristic',['max distance = ' num2str(resultCylindricGMM.maxDistances(standardMaxDistance)) ' m']})
modelCompPrecRecall.setTitle({'precision recall curve',['max distance = ' num2str(resultCylindricGMM.maxDistances(standardMaxDistance)) ' m']})
modelCompFirstN.setTitle({'search task',['max distance = ' num2str(resultCylindricGMM.maxDistances(standardMaxDistance)) ' m']})

modelCompFROC.draw()
modelCompPrecRecall.draw()
modelCompFirstN.draw(maxCandidates)

%% Clear temporaries

clear('i','colours','styles','standardMaxDistance','maxCandidates')