global datasetPath;

% change this path to point to your copy of the PASCAL VOC data
VOCopts.datadir=[fullfile(originalPWD,datasetPath) filesep];
VOCopts.imgsetpath=fullfile(VOCopts.datadir,'%s.txt');
VOCopts.annopath='%s';