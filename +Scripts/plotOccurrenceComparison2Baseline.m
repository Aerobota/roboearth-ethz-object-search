%% Parameters

plotExtremeClasses=true;
nOfExtremeClasses=5;

baselineColour='c';
baselineStyle='-';
informedColour='b';
informedStyle='-';
goodColour='g';
goodStyle='-';
badColour='r';
badStyle='-';

desiredPlots=[2 2 1;2 2 2;2 2 3;2 1 3;1 2 3];

%% Initialise

assert(exist('resultOpt','var')==1 && exist('resultThresh','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Compare to baseline

% for m=size(occLearner,1):-1:1
%     for o=size(occLearner,2):-1:1

cond2Base=cell(1,length(desiredPlots));

for p=1:length(desiredPlots)
    m=desiredPlots(p,1);
    o=desiredPlots(p,2);
    t=desiredPlots(p,3);
        
    occStr=['{' occurrenceStates{o}{1}];
    for i=2:length(occurrenceStates{o})
        occStr=[occStr ',' occurrenceStates{o}{i}];
    end
    occStr=[occStr '}'];

    description={['occurrence states = ' occStr];['value matrix = ' mat2str(valueMatrix{m})]};

    if t==1
        cond2Base{p}=Evaluation.ROCEvaluationData;
        cond2Base{p}.addData(resultThresh{m,o}.conditioned,'informed',informedColour,informedStyle)
        cond2Base{p}.addData(resultThresh{m,o}.baseline,'baseline',baselineColour,baselineStyle)
        cond2Base{p}.setTitle([{'receiver operating characteristic'};description])
    elseif t==2
        cond2Base{p}=Evaluation.PrecRecallEvaluationData;
        cond2Base{p}.addData(resultThresh{m,o}.conditioned,'informed',informedColour,informedStyle)
        cond2Base{p}.addData(resultThresh{m,o}.baseline,'baseline',baselineColour,baselineStyle)
        cond2Base{p}.setTitle([{'precision recall curve'};description])
    elseif t==3
        cond2Base{p}=Evaluation.CostOptimalEvaluationData;
        goodClasses=resultOpt{m,o}.conditioned.tp~=0 & resultOpt{m,o}.conditioned.fp~=0;
        cond2Base{p}.addData(resultOpt{m,o}.conditioned,'individual',informedColour,informedStyle,goodClasses)
        cond2Base{p}.setBaseline(resultOpt{m,o}.baseline,baselineColour)
        cond2Base{p}.setTitle([{'cost optimal decision'};description])
    end
    
    if plotExtremeClasses && t<3
        [~,bestClasses]=sort(resultThresh{m,o}.conditioned.expectedUtility,'descend');
        [~,worstClasses]=sort(resultThresh{m,o}.conditioned.expectedUtility,'ascend');
        bestClasses=bestClasses(1:min(5,end));
        worstClasses=worstClasses(1:min(5,end));
        bestText=['best ' num2str(length(bestClasses)) ' classes'];
        worstText=['worst ' num2str(length(bestClasses)) ' classes'];
        
        if t==1
            cond2Base{p}.addData(resultThresh{m,o}.conditioned,bestText,goodColour,goodStyle,bestClasses)
            cond2Base{p}.addData(resultThresh{m,o}.conditioned,worstText,badColour,badStyle,worstClasses)
        elseif t==2
            cond2Base{p}.addData(resultThresh{m,o}.conditioned,bestText,goodColour,goodStyle,bestClasses)
            cond2Base{p}.addData(resultThresh{m,o}.conditioned,worstText,badColour,badStyle,worstClasses)
        end
    end

    cond2Base{p}.draw()
end