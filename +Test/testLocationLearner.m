clear conn

%% parameters

%evidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
evidenceGenerator=LearnFunc.CylindricEvidenceGenerator();

%% load data
dataPath='Dataset/NYU';
im=DataHandlers.NYUDataStructure(dataPath,DataHandlers.NYUDataStructure.trainSet,DataHandlers.NYUDataStructure.gt);
im.load();

classes=im.getClassNames();

%% learn location structure
ll=LearnFunc.ChowLiuLocationLearner(classes,evidenceGenerator);

parents=ll.learnStructure(im);


%% build simple graph with only one node per class
g=NetFunc.BNTGraph();
conn.node='node';
for c=1:length(classes)
    node=NetFunc.BNTSimpleNode(classes{c},{'continous'});
    node.connect(parents.(genvarname(classes{c})),conn);
    g.addNode(node);
end
