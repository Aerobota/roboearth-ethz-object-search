global datasetFolder;

% change this path to point to your copy of the PASCAL VOC data
VOCopts.datadir=[datasetFolder filesep];
VOCopts.imgsetpath=fullfile(VOCopts.datadir,'%s.txt');
VOCopts.annopath='%s';