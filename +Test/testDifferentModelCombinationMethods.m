%% Parameters

standardMaxDistance=2;
maxCandidates=10;

colours={'k','b',[0 0.6 0],[0.8 0 0],[0.6 0 0.6]};
styles={'-','--'};

goodClasses=[3 12];
badClasses=[8 10];

firstNPlotType='line';
firstNPlotStyle={':*',':s',':+',':o',':x'};

%% Plot distance comparison

gmmDistancesPrecRecall=Evaluation.PrecRecallEvaluationData;
gmmDistancesFirstN=Evaluation.FirstNEvaluationData;

results={resultCylindricGMM,resultCylindricGMMAvg};
legendTexts={'orig','avg'};

for i=1:length(results)
    gmmDistancesPrecRecall.addData(results{i}.FROC{standardMaxDistance},legendTexts{i},...
        colours{mod(i-1,length(colours))+1},styles{mod(i-1,length(styles))+1});
    gmmDistancesFirstN.addData(results{i}.FirstN{standardMaxDistance},legendTexts{i},...
        colours{mod(i-1,length(colours))+1},firstNPlotStyle{mod(i-1,length(firstNPlotStyle))+1});
end

gmmDistancesPrecRecall.setTitle('precision recall curve')
gmmDistancesFirstN.setTitle('search task')

% gmmDistancesFROC.draw()
gmmDistancesPrecRecall.draw()
gmmDistancesFirstN.draw(maxCandidates,firstNPlotType)

%% Clear temporaries

clear('i','colours','styles','standardMaxDistance','maxCandidates','goodClasses','badClasses','firstNPlotType')