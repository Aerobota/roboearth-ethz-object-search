clear all;

il=DataHandlers.SunLoader('Dataset/Sun09_small');
im=il.getData(il.gtTrain);

classes={il.objects.name};

pop=LearnFunc.pairwiseOccurenceProbability(im,classes);

pmi=LearnFunc.pairwiseMutualInformation(pop);

adjacency=LearnFunc.generateChowLiu(pmi);

parents=LearnFunc.directGraph(adjacency,classes);


g=NetFunc.BNTGraph();
conn.node='node';
for c=1:length(classes)
    node=NetFunc.BNTSimpleNode(classes{c},{'0','1','2+'});
    node.connect(parents.(classes{c}),conn);
    g.addNode(node);
end


gplus=NetFunc.BNTGraph();
states.occ={'0';'1';'2+'};
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