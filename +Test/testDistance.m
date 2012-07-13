%% parameters

%evidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
evidenceGenerator=LearnFunc.CylindricEvidenceGenerator();

learnFunction='gmm';
% learnFunction='gaussian';

%% load data
disp('loading data')
dataPath='Dataset/NYU';
im=DataHandlers.NYUDataStructure(dataPath,'train','gt');
im.load();

%% learn location parameters
if strcmpi(learnFunction,'gmm')
    ll=LearnFunc.ContinuousGMMLearner(evidenceGenerator);
else
	ll=LearnFunc.ContinuousGaussianLearner(evidenceGenerator);
end
tic
ll.learnParameters(im);
learnTime=toc