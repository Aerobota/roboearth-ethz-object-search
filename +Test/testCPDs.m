clear states intConn

states.corr={'correct';'false positive'};
states.loc={'continous'};
states.score={'continous'};
intConn.score={'corr'};
intConn.loc={'corr'};

node=NetFunc.BNTStructureNode('Test',intConn,states);
g=NetFunc.BNTGraph();
g.addNode(node);

g.setCompileState(true);

nSamples=100;
pGood=0.2;
scoreMean=[0.9 1];
scoreVar=[0.3 0.2];
locMean=[0.2 1];
locVar=[0.6 0.2];

g.setCPD(g.nodes.Testcorr.index,tabular_CPD(g.net,g.nodes.Testcorr.index,[1-pGood pGood]));
g.setCPD(g.nodes.Testloc.index,gaussian_CPD(g.net,g.nodes.Testloc.index,...
    'mean',locMean,'cov',reshape(locVar,1,1,2)));
g.setCPD(g.nodes.Testscore.index,gaussian_CPD(g.net,g.nodes.Testscore.index,...
    'mean',scoreMean,'cov',reshape(scoreVar,1,1,2)));

engine=jtree_inf_engine(g.net);
evidence=cell(length(g.net.CPD),1);
evidence{g.nodes.Testloc.index}=1;
evidence{g.nodes.Testscore.index}=1;
engine=enter_evidence(engine,evidence);
marg=marginal_nodes(engine,1);

disp(marg.T)
