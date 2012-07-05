datasetPath=fullfile(pwd,'Dataset/NYU');
confidencePoints=0.5%linspace(0,0.99,30);

gtLoader=DataHandlers.NYUGTLoader(datasetPath);
detLoader=DataHandlers.NYUDetLoader(datasetPath);
blineEval=Evaluation.BaselineEvaluator(confidencePoints);

disp('loading ground truth')
gt=gtLoader.getData(gtLoader.testSet);
disp('loading detections')
det=detLoader.getData(detLoader.testSet);

disp('running detection evaluation')
precRec=blineEval.generateDetectionPerformance(det,gt);

% save('tmpPrecRec','precRec');