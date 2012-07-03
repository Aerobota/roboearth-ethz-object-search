%% Parameters
datasetPath='Dataset/NYU';

occurrenceStates={'0','1','2+'};

evidenceGeneratorName='cylindric';

%% Object initialisation
imageLoader=DataHandlers.NYUGTLoader(fullfile(pwd,datasetPath));
classes=imageLoader.getClassNames();

occurenceEvidenceGenerator=LearnFunc.PairwiseOccurenceEvidenceGenerator(occurrenceStates);

if strcmpi(evidenceGeneratorName,'cylindric')
    locationEvidenceGenerator=LearnFunc.CylindricEvidenceGenerator();
else
    locationEvidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
end

occurenceLearner=LearnFunc.ChowLiuOccurrenceLearner(classes,occurenceEvidenceGenerator);
locationLearner=LearnFunc.ChowLiuLocationLearner(classes,locationEvidenceGenerator);

%% Data loading
disp('loading data')
data=imageLoader.getData(imageLoader.trainSet);

%% Dependency learning
disp('learning occurence dependency')
occurenceDependency=occurenceLearner.learnStructure(data);
disp('learning location dependency')
locationDependency=locationLearner.learnStructure(data);

%% Parameter learning
