%% Parameters

standardOccurrenceState=1;
nOfBestClasses=5;

colours={'b',[0.8 0 0]};
styles={'-','--'};


%% Initialise

assert(exist('resultThresh','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Compare value matrices

compMatricesPrecRecall=Evaluation.PrecRecallEvaluationData;

o=standardOccurrenceState;

for m=1:size(resultThresh,1)
    compMatricesPrecRecall.addData(resultThresh{m,o}.conditioned,['value matrix = ' mat2str(valueMatrix{m})],...
        colours{mod(m-1,length(colours))+1},styles{mod(m-1,length(styles))+1})
end

compMatricesPrecRecall.setTitle('precision-recall curve')

compMatricesPrecRecall.draw()

%% Clear temporaries

clear('i','m','o','occStr','description','standardOccurrenceState','colours',...
    'styles','nOfBestClasses','bestClasses')