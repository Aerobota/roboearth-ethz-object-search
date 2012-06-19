% run the setup
%setup;
% global datasetPath;

% change this path to point to your copy of the PASCAL VOC data
VOCopts.datadir='';%datasetPath;


VOCopts.imgsetpath=fullfile(originalPWD,'VOCcode','%s.txt');
VOCopts.annopath='%s';

% change this path to a writable directory for your results
%VOCopts.resdir='/homes/me/VOCresults/';

% change this path to a writable local directory for the example code
%VOCopts.localdir='/tmp/';