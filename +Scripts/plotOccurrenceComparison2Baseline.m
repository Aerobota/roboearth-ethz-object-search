%% Parameters

plotExtremeClasses=true;
nOfExtremeClasses=5;

%desiredPlots=[2 2 1;2 2 2;2 2 3;2 1 3;1 2 3];
desiredPlots=[2 1 1;2 1 2];

colours={'k','b',[0 0.6 0],[0.8 0 0]}; %{baseline,informed,good,bad}
styles={'-','-.','--','--'};


%% Initialise

assert(exist('resultOpt','var')==1 && exist('resultThresh','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Compare to baseline

cond2Base=cell(1,size(desiredPlots,1));

for p=1:size(desiredPlots,1)
    m=desiredPlots(p,1);
    o=desiredPlots(p,2);
    t=desiredPlots(p,3);
        
    occStr=['\{' occurrenceStates{o}{1}];
    for i=2:length(occurrenceStates{o})
        occStr=[occStr ',' occurrenceStates{o}{i}];
    end
    occStr=[occStr '\}'];

    %description={['occurrence states = ' occStr];['value matrix = ' mat2str(valueMatrix{m})]};

    if t==1
        cond2Base{p}=Evaluation.ROCEvaluationData;
        cond2Base{p}.addData(resultThresh{m,o}.conditioned,'informed',colours{2},styles{2})
        cond2Base{p}.addData(resultThresh{m,o}.baseline,'baseline',colours{1},styles{1})
        %cond2Base{p}.setTitle([{'receiver operating characteristic'};description])
        cond2Base{p}.setTitle('receiver operating characteristic')
    elseif t==2
        cond2Base{p}=Evaluation.PrecRecallEvaluationData;
        cond2Base{p}.addData(resultThresh{m,o}.conditioned,'informed',colours{2},styles{2})
        cond2Base{p}.addData(resultThresh{m,o}.baseline,'baseline',colours{1},styles{1})
        %cond2Base{p}.setTitle([{'precision recall curve'};description])
        cond2Base{p}.setTitle('precision recall curve')
    elseif t==3
        cond2Base{p}=Evaluation.CostOptimalEvaluationData;
        goodClasses=resultOpt{m,o}.conditioned.tp~=0 & resultOpt{m,o}.conditioned.fp~=0;
        cond2Base{p}.addData(resultOpt{m,o}.conditioned,'individual',colours{2},styles{2},goodClasses)
        cond2Base{p}.setBaseline(resultOpt{m,o}.baseline,colours{1})
        %cond2Base{p}.setTitle([{'cost optimal decision'};description])
        cond2Base{p}.setTitle('cost optimal decision')
    end
    
    if plotExtremeClasses && t<3
        [~,bestClasses]=sort(resultThresh{m,o}.conditioned.expectedUtility,'descend');
        [~,worstClasses]=sort(resultThresh{m,o}.conditioned.expectedUtility,'ascend');
        bestClasses=bestClasses(1:min(5,end));
        worstClasses=worstClasses(1:min(5,end));
        bestText=['best ' num2str(length(bestClasses)) ' classes'];
        worstText=['worst ' num2str(length(bestClasses)) ' classes'];
        
        cond2Base{p}.addData(resultThresh{m,o}.conditioned,bestText,colours{3},styles{3},bestClasses)
        cond2Base{p}.addData(resultThresh{m,o}.conditioned,worstText,colours{4},styles{4},worstClasses)
    end

    cond2Base{p}.draw()
end

%% Clear temporaries

clear('p','m','o','t','i','bestClasses','worstClasses','bestText','worstText',...
    'goodClasses','description','occStr','colours','styles','desiredPlots',...
    'plotExtremeClasses','nOfExtremeClasses')
