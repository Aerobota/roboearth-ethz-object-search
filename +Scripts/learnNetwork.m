%% Parameters
datasetPath='Dataset/NYU';

occurrenceStates={'0','1','2+'};

evidenceGeneratorName='cylindric';

%% Object initialisation
data=DataHandlers.NYUDataStructure(datasetPath,DataHandlers.NYUDataStructure.trainSet,...
    DataHandlers.NYUDataStructure.gt);
classes=data.getClassNames();

occurenceEvidenceGenerator=LearnFunc.PairwiseOccurenceEvidenceGenerator(occurrenceStates);

if strcmpi(evidenceGeneratorName,'cylindric')
    locationEvidenceGenerator=LearnFunc.CylindricEvidenceGenerator();
else
    locationEvidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
end

occurenceLearner=LearnFunc.ChowLiuOccurrenceLearner(classes,occurenceEvidenceGenerator);
locationLearner=LearnFunc.ChowLiuLocationLearner(classes,locationEvidenceGenerator);

%% Data loading
disp('loading data')
data.load();

%% Dependency learning
disp('learning occurence dependency')
occurenceDependency=occurenceLearner.learnStructure(data);

gOcc=NetFunc.BNTGraph();
conn.node='node';
for c=1:length(classes)
    node=NetFunc.BNTSimpleNode(classes{c},occurrenceStates);
    node.connect(occurenceDependency.(genvarname(classes{c})),conn);
    gOcc.addNode(node);
end

disp('learning location dependency')
locationDependency=locationLearner.learnStructure(data);

gLoc=NetFunc.BNTGraph();
for c=1:length(classes)
    node=NetFunc.BNTSimpleNode(classes{c},{'continuous'});
    node.connect(locationDependency.(genvarname(classes{c})),conn);
    gLoc.addNode(node);
end
%% Parameter learning



%% Visualisation


