%% Parameters

desiredPlots=[2 1];

colours={'k','b',[0 0.6 0],[0.8 0 0]}; %{baseline,informed,good,bad}
styles={'-'};


%% Initialise

assert(exist('resultThresh','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Compare to baseline

compModel=cell(1,size(desiredPlots,1));

for p=1:size(desiredPlots,1)
    m=desiredPlots(p,1);
    o=desiredPlots(p,2);
    compModel{p}=Evaluation.PrecRecallEvaluationData;
    compModel{p}.addData(resultThresh{m,o,1}.conditioned,'informed',colours{2},styles{1})
    compModel{p}.addData(resultThreshNaive{o}.conditioned,'naive',colours{4},styles{1})
%     compModel{p}.addData(resultThresh{m,o,2}.conditioned,'naive reduced',colours{3},styles{1})
    compModel{p}.addData(resultThresh{m,o}.baseline,'baseline',colours{1},styles{1})
    compModel{p}.setTitle('precision-recall curve')

    compModel{p}.draw()
end

%% Clear temporaries

clear('p','m','o','colours','styles','desiredPlots')
