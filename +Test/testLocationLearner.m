clear conn

%% parameters

%evidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
evidenceGenerator=LearnFunc.CylindricEvidenceGenerator();

%% load data
dataPath='Dataset/NYU';
im=DataHandlers.NYUDataStructure(dataPath,'train','gt');
im.load();

%% learn location structure
ll=LearnFunc.ChowLiuLocationLearner(evidenceGenerator);

parents=ll.learnStructure(im);


%% build simple graph with only one node per class

classes=im.getClassNames();

g=NetFunc.BNTGraph();
conn.node='node';
for c=1:length(classes)
    node=NetFunc.BNTSimpleNode(classes{c},{'continous'});
    node.connect(parents.(genvarname(classes{c})),conn);
    g.addNode(node);
end
