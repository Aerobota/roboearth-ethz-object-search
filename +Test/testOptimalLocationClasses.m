stdDist=1;
maxCandidates=10;

gmmDistancesFirstN=Evaluation.FirstNEvaluationData;

for i=1:17
    gmmDistancesFirstN.addData(resultCylindricGMM.FirstN{stdDist},['class ' num2str(i)],...
        colours{mod(i-1,length(colours))+1},styles{mod(i-1,length(styles))+1},i);
end

gmmDistancesFirstN.setTitle('search task')

gmmDistancesFirstN.draw(maxCandidates)