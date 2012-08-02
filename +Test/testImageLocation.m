%% Parameters

maxDistances=[0.25 0.5 1 1.5];
standardMaxDistance=2;
maxCandidates=10;
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
result=evalBase.evaluate(testData,ll,evalMethod,maxDistances);
timeEval=toc;

%% Generate graphs

rocLoc=Evaluation.ROCEvaluationData;
rocLoc.addData(result.FROC{standardMaxDistance},'informed')
rocLoc.setTitle('free-response receiver operating characteristic')
rocLoc.draw()

precRecallLoc=Evaluation.PrecRecallEvaluationData;
precRecallLoc.addData(result.FROC{standardMaxDistance},'informed')
precRecallLoc.setTitle('precision recall curve')
precRecallLoc.draw()

firstNLoc=Evaluation.FirstNEvaluationData;
for i=1:length(result.FirstN)
    firstNLoc.addData(result.FirstN{i},['max distance = ' num2str(maxDistances(i)) ' m'])
end
firstNLoc.setTitle('search task')
firstNLoc.draw(maxCandidates)