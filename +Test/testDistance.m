dataPath='Dataset/Sun09_clean';
il=DataHandlers.SunLoader(dataPath);
im=il.getData(il.gtTrain);

ll=LearnFunc.ContinousZGMMLearner({il.objects.name},[il.objects.height]);
tic
ll.learnLocations(im);
learnTime=toc  