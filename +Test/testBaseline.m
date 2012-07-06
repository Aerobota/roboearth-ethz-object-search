dataPath=fullfile(pwd,'Dataset/NYU');
confidencePoints=0.3%linspace(0,0.99,30);

gt=DataHandlers.NYUDataStructure(dataPath,DataHandlers.NYUDataStructure.testSet,DataHandlers.NYUDataStructure.gt);
det=DataHandlers.NYUDataStructure(dataPath,DataHandlers.NYUDataStructure.testSet,DataHandlers.NYUDataStructure.det);
blineEval=Evaluation.BaselineEvaluator(confidencePoints);

disp('loading ground truth')
gt.load();
disp('loading detections')
det.load();

disp('running detection evaluation')
precRec=blineEval.evaluateDetectionPerformance(det,gt);

save('tmpPrecRec','precRec');