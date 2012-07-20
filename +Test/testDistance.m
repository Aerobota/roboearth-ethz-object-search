%% parameters

datasetPath='Dataset/NYU';

% evidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
evidenceGenerator=LearnFunc.CylindricEvidenceGenerator();

learnFunction='gmm';
% learnFunction='gaussian';

%% load data
disp('loading data')
trainData=DataHandlers.NYUDataStructure(datasetPath,'train');
trainData.load();

testData=DataHandlers.NYUDataStructure(datasetPath,'test');
testData.load();

%% learn location parameters
if strcmpi(learnFunction,'gmm')
    ll=LearnFunc.ContinuousGMMLearner(evidenceGenerator);
else
	ll=LearnFunc.ContinuousGaussianLearner(evidenceGenerator);
end
tic
ll.learn(trainData);
learnTime=toc;

%% buffer the evaluation data for the test data

tic
ll.bufferTestData(testData)
bufferTime=toc;