%% Parameters

maxDistances=[0.25 0.5 1 1.5];
standardMaxDistance=3;
evalMethod{1}=Evaluation.FROCLocationEvaluator;
evalMethod{2}=Evaluation.FirstNLocationEvaluator;

%% Initialise

disp('initialising')

Scripts.setPaths

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train');

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test');

locVerticalDistEviGen=LearnFunc.VerticalDistanceEvidenceGenerator();
locCylindricEviGen=LearnFunc.CylindricEvidenceGenerator();

locLearnVerticalDistGMM=LearnFunc.ContinuousGMMLearner(locVerticalDistEviGen);
locLearnCylindricGMM=LearnFunc.ContinuousGMMLearner(locCylindricEviGen);
locLearnCylindricGaussian=LearnFunc.ContinuousGaussianLearner(locCylindricEviGen);

evalBase=Evaluation.LocationEvaluator();

%% Load data

disp('loading data')

dataTrain.load();
dataTest.load();

%% Learn probabilities

disp('learning')

locLearnVerticalDistGMM.learn(dataTrain)
locLearnCylindricGMM.learn(dataTrain)
locLearnCylindricGaussian.learn(dataTrain)

%% Evaluate Test Images

disp('evaluating')

resultVerticalDistGMM=evalBase.evaluate(testData,locLearnVerticalDistGMM,evalMethod,maxDistances(standardMaxDistance));
resultCylindricGMM=evalBase.evaluate(testData,locLearnCylindricGMM,evalMethod,maxDistances);
resultCylindricGaussian=evalBase.evaluate(testData,locLearnCylindricGaussian,evalMethod,maxDistances(standardMaxDistance));

%% Clear temporaries

clear('dataTrain','dataTest','locVerticalDistEviGen','locCylindricEviGen',...
    'evalBase','sourceFolder','datasetPath')

%% Save results to file

save('tmpLocationData.mat','locLearnVerticalDistGMM','locLearnCylindricGMM','locLearnCylindricGaussian',...
    'resultVerticalDistGMM','resultCylindricGMM','resultCylindricGaussian',...
    'maxDistances','standardMaxDistance','evalMethod')