clear all;


%% parameters
dataPath='Dataset/NYU';
multiOccurence=true;

%% load dataset
im=DataHandlers.NYUDataStructure(dataPath,DataHandlers.NYUDataStructure.trainSet,DataHandlers.NYUDataStructure.gt);
im.load();


%% learn chow liu
if multiOccurence
    occurrenceStates={'0','1','2+'};
else
    occurrenceStates={'0','1+'};
end

CLLearner=LearnFunc.ChowLiuOccurrenceLearner(LearnFunc.PairwiseOccurrenceEvidenceGenerator(occurrenceStates));

parents=CLLearner.learnStructure(im);


%% build simple graph with only one node per class
classes=im.getClassNames();

g=NetFunc.BNTGraph();
conn.node='node';
for c=1:length(classes)
    node=NetFunc.BNTSimpleNode(classes{c},occurrenceStates);
    node.connect(parents.(genvarname(classes{c})),conn);
    g.addNode(node);
end

%% build complex graph with subnodes for occurence, location and correctness per class
gplus=NetFunc.BNTGraph();
states.occ=occurrenceStates;
states.loc={'here';'there'};
states.corr={'false';'positive'};
extConn.occ={'occ'};
extConn.loc={'occ';'loc'};
intConn.loc={'occ'};
intConn.corr={'occ';'loc'};
for c=1:length(classes)
    node=NetFunc.BNTStructureNode(classes{c},intConn,states);
    node.connect(parents.(genvarname(classes{c})),extConn);
    gplus.addNode(node);
end