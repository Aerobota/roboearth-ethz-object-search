dataPath=fullfile(pwd,'Dataset/NYU');
confidencePoints=linspace(0,0.99,30);

gt=DataHandlers.NYUDataStructure(dataPath,DataHandlers.NYUDataStructure.trainSet,DataHandlers.NYUDataStructure.gt);
det=DataHandlers.SunDataStructure(dataPath,DataHandlers.SunDataStructure.trainSet,DataHandlers.SunDataStructure.gt);
blineEval=Evaluation.BaselineEvaluator(confidencePoints);

disp('loading ground truth')
gt.load();
disp('loading detections')
det.load();

disp('running detection evaluation')
precRec=blineEval.evaluateDetectionPerformance(det,gt);

save('tmpPrecRec','precRec');