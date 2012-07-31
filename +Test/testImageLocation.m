%% Parameters

maxDistances=[0.25 0.5 1 1.5];
evalMethod{1}=Evaluation.FROCLocationEvaluator;
evalMethod{2}=Evaluation.FirstNLocationEvaluator;

%% Init

if exist('ll','var')~=1 || ~isa(ll,'LearnFunc.Learner')
    error('Need to run Test.testDistance first')
end

%% Load data

testData=DataHandlers.NYUDataStructure(datasetPath,'test');
testData.load();

%% Run evaluator

evalBase=Evaluation.LocationEvaluator();
tic
result=evalBase.evaluate(ll,testData,evalMethod,maxDistances);
timeEval=toc;
