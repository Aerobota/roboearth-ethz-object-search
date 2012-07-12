%% parameters

%evidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
evidenceGenerator=LearnFunc.CylindricEvidenceGenerator();

learnFunction='gmm';
% learnFunction='gaussian';

%% load data
dataPath='Dataset/NYU';
im=DataHandlers.NYUDataStructure(dataPath,'train','gt');
im.load();

%% learn location parameters
if strcmpi(learnFunction,'gmm')
    ll=LearnFunc.ContinousGMMLearner(evidenceGenerator);
else
	ll=LearnFunc.ContinousGaussianLearner(evidenceGenerator);
end
tic
ll.learnParameters(im);
learnTime=toc