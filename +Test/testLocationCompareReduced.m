%% Initialise

assert(exist('resultCylindricGMM','var')==1 && exist('resultCylindricGMMReduced','var')==1,...
    'Scripts.computeLocationData needs to be run before this script.')

%% Parameters

standardMaxDistance=2;
maxCandidates=10;

colours={'k','b',[0 0.6 0],[0.8 0 0],[0.6 0 0.6]};
styles={'-','--'};

firstNPlotType='line';
firstNPlotStyle={':*',':s',':+',':o',':x'};

%% Plot parent selection comparison

gmmDistancesPrecRecall=Evaluation.PrecRecallEvaluationData;
gmmDistancesFirstN=Evaluation.FirstNEvaluationData(maxCandidates,firstNPlotType);

gmmDistancesPrecRecall.addData(resultCylindricGMM.FROC{standardMaxDistance},'all',...
    colours{mod(0,length(colours))+1},styles{mod(0,length(styles))+1});
gmmDistancesFirstN.addData(resultCylindricGMM.FirstN{standardMaxDistance},'all',...
    colours{mod(0,length(colours))+1},firstNPlotStyle{mod(0,length(firstNPlotStyle))+1});

gmmDistancesPrecRecall.addData(resultCylindricGMMReduced.FROC{1},'reduced',...
    colours{mod(1,length(colours))+1},styles{mod(1,length(styles))+1});
gmmDistancesFirstN.addData(resultCylindricGMMReduced.FirstN{1},'reduced',...
    colours{mod(1,length(colours))+1},firstNPlotStyle{mod(1,length(firstNPlotStyle))+1});

gmmDistancesPrecRecall.setTitle('precision-recall curve')
gmmDistancesFirstN.setTitle('search task')

gmmDistancesPrecRecall.draw()
gmmDistancesFirstN.draw()