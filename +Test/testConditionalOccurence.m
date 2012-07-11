%% Parameters

datasetPath='Dataset/NYU';
occurrenceStates={'0','1','2+'};


%% Initialise

dataTrain=DataHandlers.NYUDataStructure(datasetPath,DataHandlers.NYUDataStructure.trainSet,DataHandlers.NYUDataStructure.gt);
dataTrain.load();
dataTrain.bufferObjects();

dataTest=DataHandlers.NYUDataStructure(datasetPath,DataHandlers.NYUDataStructure.testSet,DataHandlers.NYUDataStructure.gt);
dataTest.load();
dataTest.bufferObjects();

classes=dataTrain.getClassNames;
classesLarge=classes([3 4 5 6 8 11 13 15 17 19 20 21 23 24 27 28 29 30 31 34 40 41 42 43]);

evidenceGenerator=LearnFunc.CooccurrenceEvidenceGenerator(occurrenceStates);

% evidence=evidenceGenerator.getEvidence(dataTrain,classes,1);

learner=LearnFunc.ConditionalOccurrenceLearner(classes,evidenceGenerator,classesLarge);

%% Learn probabilities

learner.learnStructure(dataTrain);

%% Evaluate Test Image

% testImage=3;
% testClasses={'cup','paper','faucet','towel'};
% 
% objects=dataTest.getObject(testImage);
% largeCount=zeros(size(classesLarge));
% testCount=zeros(size(testClasses));
% 
% for o=1:length(objects)
%     tf=ismember(classesLarge,objects(o).name);
%     largeCount(tf)=largeCount(tf)+1;
%     
%     tf=ismember(testClasses,objects(o).name);
%     testCount(tf)=testCount(tf)+1;
% end
% 
% largeStates=evidenceGenerator.getStateIndices(largeCount);
% testStates=evidenceGenerator.getStateIndices(testCount);
% 
% posterior=zeros(length(occurrenceStates),length(testClasses));
% for t=1:length(testClasses)
%     for l=1:length(classesLarge)
%         posterior(:,t)=posterior(:,t)+log(learner.data.(testClasses{t}).(classesLarge{l})(:,largeStates(l)));
%     end
% end
% 
% posterior=exp(posterior);
% posterior=posterior./repmat(sum(posterior),[3 1]);
% 
% posterior2=ones(length(occurrenceStates),length(testClasses));
% for t=1:length(testClasses)
%     for l=1:length(classesLarge)
%         posterior2(:,t)=posterior2(:,t)+learner.data.(testClasses{t}).(classesLarge{l})(:,largeStates(l));
%     end
% end
% 
% posterior2=posterior2./repmat(sum(posterior2),[3 1]);