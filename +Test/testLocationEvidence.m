%% parameters

dataPath='Dataset/NYU';

%evidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
evidenceGenerator=LearnFunc.CylindricEvidenceGenerator();

%% load data
disp('loading data')
im=DataHandlers.NYUDataStructure(dataPath,'train','gt');
im.load();

%% getEvidence

relEvi=evidenceGenerator.getEvidence(im,'relative');
absEvi=evidenceGenerator.getEvidence(im,'absolute');