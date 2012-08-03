%% Parameters

maxDistances=[0.25 0.5 1 1.5];
evalMethod{1}=Evaluation.FROCLocationEvaluator;
evalMethod{2}=Evaluation.FirstNLocationEvaluator;

%% Initialise

disp('initialising')

Scripts.setPaths

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train');

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test');

locCylindricEviGen=LearnFunc.CylindricEvidenceGenerator();

locLearnCylindricGMM=LearnFunc.ContinuousGMMLearner(locCylindricEviGen);
locLearnCylindricGaussian=LearnFunc.ContinuousGaussianLearner(locCylindricEviGen);

evalBase=Evaluation.LocationEvaluator();

%% Load data

disp('loading data')

dataTrain.load();
dataTest.load();

%% Learn probabilities

disp('learning')

locLearnCylindricGMM.learn(dataTrain)
locLearnCylindricGaussian.learn(dataTrain)

%% Evaluate Test Images

disp('evaluating')

resultCylindricGMM=evalBase.evaluate(dataTest,locLearnCylindricGMM,evalMethod,maxDistances);
resultCylindricGaussian=evalBase.evaluate(dataTest,locLearnCylindricGaussian,evalMethod,maxDistances);

%% Clear temporaries

clear('dataTrain','dataTest','locCylindricEviGen','evalBase','sourceFolder','datasetPath')

%% Save results to file

save('tmpLocationData.mat','locLearnCylindricGMM','locLearnCylindricGaussian',...
    'resultCylindricGMM','resultCylindricGaussian','maxDistances','evalMethod')