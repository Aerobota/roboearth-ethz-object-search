clear all

%% toy graph hardcoded
o=NetFunc.BNTGraph();

a=NetFunc.BNTSimpleNode('first',{'false';'true'});
b=NetFunc.BNTSimpleNode('second',{'false';'true'});
c=NetFunc.BNTSimpleNode('third',{'false';'true'});

states.loc={'close';'far'};
states.occurence={'none';'few';'many'};
intConn.loc={'occurence'};
d=NetFunc.BNTStructureNode('fourth',intConn,states);

a.connect(b);
a.connect(c);
b.connect(c);

conn.occurence={''};
d.connect('second',conn);

o.addNode(a);
o.addNode(b);
o.addNode(c);
o.addNode(d);

o.viewGraph();

%% toy graph programmatic

o2=NetFunc.BNTGraph();

classes={'sheep';'chair';'sky';'tree'};

parents.(classes{1})=classes{4};
parents.(classes{2})=classes{3};
parents.(classes{3})=[];
parents.(classes{4})=classes{3};

%states and intConn is same as above plus more
states.boundingbox=[];
states.score=[];
states.correctness={'false positive';'true positive'};
intConn.loc={'occurence';'correctness'};
intConn.boundingbox={'loc'};
intConn.score={'correctness'};
intConn.correctness={'occurence'};

extConn.occurence={'occurence'};
extConn.loc={'occurence';'loc'};

classConn.occurence='';

for i=1:length(classes)
    tmpNode=NetFunc.BNTStructureNode(classes{i},intConn,states);
    if ~isempty(parents.(classes{i}))
        tmpNode.connect(parents.(classes{i}),extConn);
    end
    tmpNode.connect('scene',classConn);
    o2.addNode(tmpNode);
end
classifierNode=NetFunc.BNTSimpleNode('scene',{'indoor';'outdoor'});
o2.addNode(classifierNode);

o2.viewGraph();