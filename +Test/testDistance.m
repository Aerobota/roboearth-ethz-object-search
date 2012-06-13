dataPath='Dataset/Sun09_clean';
il=DataHandlers.SunLoader(dataPath);
im=il.getData(il.gtTrain);

ll=LearnFunc.Continous2DLearner({il.objects.name},[il.objects.height]);
ll.learnLocations(im);
     