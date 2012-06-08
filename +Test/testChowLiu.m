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