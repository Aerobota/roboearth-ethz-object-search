Ntrain=1.2500e4;
Ntest=100;

getData=@(N) [1*randn(N,2);1*randn(N,2)+0.3];
getClasses=@(N) [ones(N,1);2*ones(N,1)];


trainData=getData(Ntrain);
trainClasses=getClasses(Ntrain);

testData=getData(Ntest);
testClasses=getClasses(Ntest);



b=mnrfit(trainData,trainClasses)

pred=mnrval(b,testData);

figure()
scatter(trainData(:,1),trainData(:,2),5*trainClasses.^2,trainClasses)

figure()
scatter(testData(:,1),testData(:,2),5*testClasses.^2,pred(:,1))

% 
% nodeSoft=NetFunc.BNTSimpleNode('softmax',{'true','false'});
% nodeRoot=NetFunc.BNTSimpleNode('root',{'continuous'});
% 
% conn.node={'node'};
% nodeSoft.connect('root',conn);
% 
% net=NetFunc.BNTGraph();
% 
% net.addNode(nodeSoft);
% net.addNode(nodeRoot);
% 
% net.setCompileState(true)
% 
% net.setCPD('rootnode',@root_CPD)
% 
% softMaxCPD=softmax_CPD(net.net,1,'offset',b(1),'weights',b(2:end));

dag=[0 1;0 0];
discrete=2;
ns=[2 2];
observed=1;

bnet=mk_bnet(dag,ns,'discrete',discrete,'observed',observed);
bnet.CPD{1}=root_CPD(bnet,1);
bnet.CPD{2}=softmax_CPD(bnet,2,'weights',b(2:end),'offset',b(1));
engine=jtree_inf_engine(bnet);
evi=cell(1,2);
evi{1}=testData(1,:);
engine=enter_evidence(engine,evi);
T=marginal_nodes(engine,2)