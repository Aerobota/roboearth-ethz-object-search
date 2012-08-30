%% Parameters

standardOccurrenceState=1;
nOfBestClasses=5;

colours={'b',[0.8 0 0]};
styles={'-','--'};


%% Initialise

assert(exist('resultThresh','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Compare value matrices

% compMatricesROC=Evaluation.ROCEvaluationData;
compMatricesPrecRecall=Evaluation.PrecRecallEvaluationData;
% compMatricesROCBest=Evaluation.ROCEvaluationData;
% compMatricesPrecRecallBest=Evaluation.PrecRecallEvaluationData;

o=standardOccurrenceState;

for m=1:size(resultThresh,1)
%     compMatricesROC.addData(resultThresh{m,o}.conditioned,['value matrix = ' mat2str(valueMatrix{m})],...
%         colours{mod(m-1,length(colours))+1},styles{mod(m-1,length(styles))+1})
    compMatricesPrecRecall.addData(resultThresh{m,o}.conditioned,['value matrix = ' mat2str(valueMatrix{m})],...
        colours{mod(m-1,length(colours))+1},styles{mod(m-1,length(styles))+1})
%     
%     [~,bestClasses]=sort(resultThresh{m,o}.conditioned.expectedUtility,'descend');
%     bestClasses=bestClasses(1:min(5,end));
%     
%     compMatricesROCBest.addData(resultThresh{m,o}.conditioned,['value matrix = ' mat2str(valueMatrix{m})],...
%         colours{mod(m-1,length(colours))+1},styles{mod(m-1,length(styles))+1},bestClasses)
%     compMatricesPrecRecallBest.addData(resultThresh{m,o}.conditioned,['value matrix = ' mat2str(valueMatrix{m})],...
%         colours{mod(m-1,length(colours))+1},styles{mod(m-1,length(styles))+1},bestClasses)
end
% 
% occStr=['\{' occurrenceStates{o}{1}];
% for i=2:length(occurrenceStates{o})
%     occStr=[occStr ',' occurrenceStates{o}{i}];
% end
% occStr=[occStr '\}'];
% 
% description=['occurrence states = ' occStr]

% compMatricesROC.setTitle({'receiver operating characteristic';description})
% compMatricesROC.setTitle('receiver operating characteristic')
compMatricesPrecRecall.setTitle('precision recall curve')
% 
% compMatricesROCBest.setTitle({['receiver operating characteristic for best '...
%     num2str(nOfBestClasses) ' classes'];description})
% compMatricesPrecRecallBest.setTitle({['precision recall curve for best '...
%     num2str(nOfBestClasses) ' classes'];description})

% compMatricesROC.draw()
compMatricesPrecRecall.draw()
% 
% compMatricesROCBest.draw()
% compMatricesPrecRecallBest.draw()

%% Clear temporaries

clear('i','m','o','occStr','description','standardOccurrenceState','colours','styles','nOfBestClasses','bestClasses')