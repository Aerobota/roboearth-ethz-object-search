%% Parameters

datasetPath='Dataset/NYU';
occurrenceStates={'0','1','2+'};
maxParents=10; % if maxParents is set too large the conditional probabilities will consume a lot of memory

%% Initialise

dataTrain=DataHandlers.NYUDataStructure(datasetPath,DataHandlers.NYUDataStructure.trainSet,DataHandlers.NYUDataStructure.gt);
dataTrain.load();

dataTest=DataHandlers.NYUDataStructure(datasetPath,DataHandlers.NYUDataStructure.testSet,DataHandlers.NYUDataStructure.gt);
dataTest.load();

classes=dataTrain.getClassNames;
classesLarge=classes([3 4 5 6 8 11 13 15 17 19 20 21 23 24 27 28 29 30 31 34 40 41 42 43]);

evidenceGenerator=LearnFunc.CooccurrenceEvidenceGenerator(occurrenceStates);

learner=LearnFunc.ConditionalOccurrenceLearner(classes,evidenceGenerator,classesLarge,maxParents);

%% Learn probabilities

dependencies=learner.learnStructure(dataTrain);

%% Evaluate Test Image

