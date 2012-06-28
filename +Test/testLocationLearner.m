clear all

%% parameters

%evidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
evidenceGenerator=LearnFunc.CylindricEvidenceGenerator();

%% load data
dataPath='Dataset/NYU';
ilgt=DataHandlers.NYUGTLoader(dataPath);
im=ilgt.getData(ilgt.trainSet);

classes={ilgt.classes.name};

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
