clear all;


%% parameters
datasetPath='Dataset/NYU';
multiOccurence=true;

%% load dataset
ilgt=DataHandlers.NYUGTLoader(datasetPath);
im=ilgt.getData(ilgt.trainSet);

classes={ilgt.classes.name};

%% learn chow liu
if multiOccurence
    occurrenceStates={'0','1','2+'};
else
    occurrenceStates={'0','1+'};
end

CLLearner=LearnFunc.ChowLiuOccurrenceLearner(occurrenceStates);

parents=CLLearner.learnStructure(im,classes);

% pp=LearnFunc.PairwiseProbability(occurenceStates);
% 
% pop=pp.occurenceProbability(im,classes);
% 
% pmi=pp.mutualInformation(pop);
% 
% %% learn chow-liu tree
% adjacency=LearnFunc.generateChowLiu(pmi);
% 
% parents=LearnFunc.directGraph(adjacency,classes);


%% build simple graph with only one node per class
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