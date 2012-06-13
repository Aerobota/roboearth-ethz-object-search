clear all;


%% parameters
datasetPath='Dataset/Sun09_small';
multiOccurence=true;

%% load dataset
il=DataHandlers.SunLoader(datasetPath);
im=il.getData(il.gtTrain);

classes={il.objects.name};

%% learn mutual information
if multiOccurence
    occurenceStates={'0','1','2+'};
else
    occurenceStates={'0','1+'};
end

pp=LearnFunc.PairwiseProbability(occurenceStates);

pop=pp.occurenceProbability(im,classes);

pmi=pp.mutualInformation(pop);

%% learn chow-liu tree
adjacency=LearnFunc.generateChowLiu(pmi);

parents=LearnFunc.directGraph(adjacency,classes);


%% build simple graph with only one node per class
g=NetFunc.BNTGraph();
conn.node='node';
for c=1:length(classes)
    node=NetFunc.BNTSimpleNode(classes{c},occurenceStates);
    node.connect(parents.(classes{c}),conn);
    g.addNode(node);
end

%% build complex graph with subnodes for occurence, location and correctness per class
gplus=NetFunc.BNTGraph();
states.occ=occurenceStates;
states.loc={'here';'there'};
states.corr={'false';'positive'};
extConn.occ={'occ'};
extConn.loc={'occ';'loc'};
intConn.loc={'occ'};
intConn.corr={'occ';'loc'};
for c=1:length(classes)
    node=NetFunc.BNTStructureNode(classes{c},intConn,states);
    node.connect(parents.(classes{c}),extConn);
    gplus.addNode(node);
end