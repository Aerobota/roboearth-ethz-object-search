%% Parameters

maxDistances=0.5;
evalMethod{1}=Evaluation.FROCLocationEvaluator;
evalMethod{2}=Evaluation.FirstNLocationEvaluator;

occurrenceStates={'0','1+'};
valueMatrix=[0 -1;-0.5 1];

%% Initialise

disp('initialising')

Scripts.setPaths

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train');

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test');

locCylindricEviGen=LearnFunc.CylindricEvidenceGenerator();

locLearnCylindricGMMReduced=LearnFunc.ContinuousGMMLearner(locCylindricEviGen);

occEviGen=LearnFunc.ConditionalOccurrenceEvidenceGenerator(occurrenceStates);

occLearn=LearnFunc.ExpectedUtilityOccurrenceLearner(occEviGen,valueMatrix);

evalBase=Evaluation.LocationEvaluator();

%% Load data

disp('loading data')

dataTrain.load();
dataTest.load();

%% Learn probabilities

disp('learning')

occLearn.learn(dataTrain)
locLearnCylindricGMMReduced.learn(dataTrain)

%% Reduce Parents

tmpNames=locLearnCylindricGMMReduced.getLearnedClasses();
for i=1:length(tmpNames)
    if isfield(occLearn.model,tmpNames{i})
        locLearnCylindricGMMReduced.removeParents(tmpNames{i},setdiff(...
            fieldnames(locLearnCylindricGMMReduced.model.(tmpNames{i})),...
            occLearn.model.(tmpNames{i}).parents));
    else
        locLearnCylindricGMMReduced.removeParents(tmpNames{i},...
            fieldnames(locLearnCylindricGMMReduced.model.(tmpNames{i})));
    end
end

%% Evaluate Test Images

disp('evaluating')

resultCylindricGMMReduced=evalBase.evaluate(dataTest,locLearnCylindricGMMReduced,evalMethod,maxDistances);

%% Clear temporaries

clear('i','tmpNames','dataTrain','dataTest','locCylindricEviGen','evalBase',...
    'sourceFolder','datasetPath','occurrenceStates','valueMatrix','occEviGen')

%% Save results to file

save('tmpTestLocationParentsData.mat','locLearnCylindricGMMReduced','resultCylindricGMMReduced',...
    'evalMethod','occLearn')