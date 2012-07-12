dataPath=fullfile(pwd,'Dataset/NYU');
confidencePoints=0.3%linspace(0,0.99,30);

gt=DataHandlers.NYUDataStructure(dataPath,'test','gt');
det=DataHandlers.NYUDataStructure(dataPath,'test','det');
blineEval=Evaluation.BaselineEvaluator(confidencePoints);

disp('loading ground truth')
gt.load();
disp('loading detections')
det.load();

disp('running detection evaluation')
precRec=blineEval.evaluateDetectionPerformance(det,gt);

save('tmpPrecRec','precRec');