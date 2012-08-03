%% Parameters

standardValueMatrix=2;
nOfBestClasses=5;

colours={'c','b','g','r'};
styles={'-','-.','--',':'};


%% Initialise

assert(exist('resultThresh','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Compare value matrices

compStatesROC=Evaluation.ROCEvaluationData;
compStatesPrecRecall=Evaluation.PrecRecallEvaluationData;
compStatesROCBest=Evaluation.ROCEvaluationData;
compStatesPrecRecallBest=Evaluation.PrecRecallEvaluationData;

m=standardValueMatrix;

for o=1:size(resultThresh,2)
    occStr=['\{' occurrenceStates{o}{1}];
    for i=2:length(occurrenceStates{o})
        occStr=[occStr ',' occurrenceStates{o}{i}];
    end
    occStr=[occStr '\}'];

    description=['occurrence states = ' occStr];
    
    compStatesROC.addData(resultThresh{m,o}.conditioned,description,...
        colours{mod(o-1,length(colours))+1},styles{mod(o-1,length(styles))+1})
    compStatesPrecRecall.addData(resultThresh{m,o}.conditioned,description,...
        colours{mod(o-1,length(colours))+1},styles{mod(o-1,length(styles))+1})
    
    [~,bestClasses]=sort(resultThresh{m,o}.conditioned.expectedUtility,'descend');
    bestClasses=bestClasses(1:min(5,end));
    
    compStatesROCBest.addData(resultThresh{m,o}.conditioned,description,...
        colours{mod(o-1,length(colours))+1},styles{mod(o-1,length(styles))+1},bestClasses)
    compStatesPrecRecallBest.addData(resultThresh{m,o}.conditioned,description,...
        colours{mod(o-1,length(colours))+1},styles{mod(o-1,length(styles))+1},bestClasses)
end



compStatesROC.setTitle({'receiver operating characteristic';['value matrix = ' mat2str(valueMatrix{m})]})
compStatesPrecRecall.setTitle({'precision recall curve';['value matrix = ' mat2str(valueMatrix{m})]})

compStatesROCBest.setTitle({['receiver operating characteristic for best '...
    num2str(nOfBestClasses) ' classes'];['value matrix = ' mat2str(valueMatrix{m})]})
compStatesPrecRecallBest.setTitle({['precision recall curve for best '...
    num2str(nOfBestClasses) ' classes'];['value matrix = ' mat2str(valueMatrix{m})]})

compStatesROC.draw()
compStatesPrecRecall.draw()

compStatesROCBest.draw()
compStatesPrecRecallBest.draw()

%% Clear temporaries

clear('i','m','o','occStr','description','standardValueMatrix','colours','styles')