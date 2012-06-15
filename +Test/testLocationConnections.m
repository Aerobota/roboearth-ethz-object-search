clear all;


%% parameters
datasetPath='Dataset/Sun09_clean';
%multiOccurence=true;

%% load dataset
ilgt=DataHandlers.SunGTLoader(datasetPath);
ildet=DataHandlers.SunDetLoader(datasetPath);
gtTrain=ilgt.getData(ilgt.trainSet);
detTrain=ildet.getData(ildet.trainSet);

classes={ilgt.classes.name};


%% build chow liu
pp=LearnFunc.PairwiseProbability({'0','1','2','3+'});
pop=pp.occurenceProbability(gtTrain,classes);
pmi=pp.mutualInformation(pop);
adjacency=LearnFunc.generateChowLiu(pmi);


%% build simple graph with only one node per class for connection visualization
parents=LearnFunc.directGraph(adjacency,classes);

g=NetFunc.BNTGraph();
conn.node='node';
for c=1:length(classes)
    node=NetFunc.BNTSimpleNode(classes{c},{'continous'});
    node.connect(parents.(classes{c}),conn);
    g.addNode(node);
end

nrLocNodes=zeros(length(detTrain),1);
for i=1:length(detTrain)
    names={detTrain(i).annotation.object.name}';
    occ=sum(strcmpi(repmat(classes,length(names),1),repmat(names,1,length(classes))));
    nrLocNodes(i)=sum(sum(adjacency.*max(occ'*occ-diag(occ),0)));
end
min(nrLocNodes)
max(nrLocNodes)
mean(nrLocNodes)