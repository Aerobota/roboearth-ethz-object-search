%% Parameters

plotExtremeClasses=true;
nOfExtremeClasses=5;

desiredPlots=[2 1 2];

colours={'k','b',[0 0.6 0],[0.8 0 0]}; %{baseline,informed,good,bad}
styles={'-','-.','--','--'};


%% Initialise

assert(exist('resultThresh','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Compare to baseline

compClass=cell(1,size(desiredPlots,1));

for p=1:size(desiredPlots,1)
    m=desiredPlots(p,1);
    o=desiredPlots(p,2);
    t=desiredPlots(p,3);

    if t==1
        compClass{p}=Evaluation.ROCEvaluationData;
        compClass{p}.addData(resultThresh{m,o}.conditioned,'all',colours{2},styles{2})
        compClass{p}.setTitle('receiver operating characteristic')
    elseif t==2
        compClass{p}=Evaluation.PrecRecallEvaluationData;
        compClass{p}.addData(resultThresh{m,o}.conditioned,'all',colours{2},styles{2})
        compClass{p}.setTitle('precision-recall curve')
    end
    
    if plotExtremeClasses
        [~,bestClasses]=sort(resultThresh{m,o}.conditioned.expectedUtility,'descend');
        [~,worstClasses]=sort(resultThresh{m,o}.conditioned.expectedUtility,'ascend');
        bestClasses=bestClasses(1:min(5,end));
        worstClasses=worstClasses(1:min(5,end));
        bestText=['best ' num2str(length(bestClasses))];
        worstText=['worst ' num2str(length(bestClasses))];
        
        compClass{p}.addData(resultThresh{m,o}.conditioned,bestText,colours{3},styles{3},bestClasses)
        compClass{p}.addData(resultThresh{m,o}.conditioned,worstText,colours{4},styles{4},worstClasses)
    end

    compClass{p}.draw()
end

%% Clear temporaries

clear('p','m','o','t','i','bestClasses','worstClasses','bestText','worstText',...
    'goodClasses','description','occStr','colours','styles','desiredPlots',...
    'plotExtremeClasses','nOfExtremeClasses')
