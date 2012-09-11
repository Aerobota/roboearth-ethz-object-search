%% Parameters

standardValueMatrix=2;
nOfBestClasses=5;

colours={'b',[0.8 0 0]};
styles={'-','--'};


%% Initialise

assert(exist('resultThresh','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Compare value matrices

compStatesPrecRecall=Evaluation.PrecRecallEvaluationData;

m=standardValueMatrix;

for o=1:size(resultThresh,2)
    occStr=['\{' occurrenceStates{o}{1}];
    for i=2:length(occurrenceStates{o})
        occStr=[occStr ',' occurrenceStates{o}{i}];
    end
    occStr=[occStr '\}'];

    description=['prob. space = ' occStr];
    
    compStatesPrecRecall.addData(resultThresh{m,o}.conditioned,description,...
        colours{mod(o-1,length(colours))+1},styles{mod(o-1,length(styles))+1})
end

compStatesPrecRecall.setTitle('precision-recall curve')

compStatesPrecRecall.draw()

%% Clear temporaries

clear('i','m','o','occStr','description','standardValueMatrix','colours','styles','nOfBestClasses','bestClasses')