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