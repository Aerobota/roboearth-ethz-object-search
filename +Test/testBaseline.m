datasetPath=fullfile(pwd,'Dataset/NYU');
confidencePoints=linspace(0,0.99,30);

gtLoader=DataHandlers.NYUGTLoader(datasetPath);
detLoader=DataHandlers.NYUDetLoader(datasetPath);
blineEval=Evaluation.BaselineEvaluator(confidencePoints);

disp('loading ground truth')
gt=gtLoader.getData(gtLoader.testSet);
disp('loading detections')
det=detLoader.getData(detLoader.testSet);

disp('running detection evaluation')
precRec=blineEval.evaluateDetectionPerformance(det,gt);

save('tmpPrecRec','precRec');