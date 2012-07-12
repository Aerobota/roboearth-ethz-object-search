%% Parameters

datasetPath='Dataset/NYU';
occurrenceStates={'0','1','2+'};
maxParents=10; % if maxParents is set too large the conditional probabilities will consume a lot of memory
valueMatrix=[0 -1;-0.5 1];

%% Initialise

dataTrain=DataHandlers.NYUDataStructure(datasetPath,'train','gt');
dataTrain.load();

dataTest=DataHandlers.NYUDataStructure(datasetPath,'test','gt');
dataTest.load();

classes=dataTrain.getClassNames;
classesSmall=classes([1 2 7 9 10 12 14 16 18 22 25 26 32 33 35 36 37 38 39]);

evidenceGenerator=LearnFunc.CooccurrenceEvidenceGenerator(occurrenceStates);

learner=LearnFunc.ConditionalOccurrenceLearner(evidenceGenerator,classesSmall,valueMatrix);

%% Learn probabilities

dependencies=learner.learnStructure(dataTrain);

%% Evaluate Test Image

