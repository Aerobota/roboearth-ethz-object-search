%% parameters

datasetPath='Dataset/NYU';

% evidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
evidenceGenerator=LearnFunc.CylindricEvidenceGenerator();

learnFunction='gmm';
% learnFunction='gaussian';

%% load data
disp('loading data')
im=DataHandlers.NYUDataStructure(datasetPath,'train');
im.load();

%% learn location parameters
if strcmpi(learnFunction,'gmm')
    ll=LearnFunc.ContinuousGMMLearner(evidenceGenerator);
else
	ll=LearnFunc.ContinuousGaussianLearner(evidenceGenerator);
end
tic
ll.learn(im);
learnTime=toc