%% Parameters

datasetPath='Dataset/NYU';
imageNr=20;
targetClass='faucet';

% evidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
evidenceGenerator=LearnFunc.CylindricEvidenceGenerator();

%% Init

data=DataHandlers.NYUDataStructure(datasetPath,'test','gt');
data.load();

%% Get evidence

classes=data.getClassNames;
classesSmall=classes([1 2 7 9 10 12 14 16 18 22 25 26 32 33 35 36 37 38 39]);
baseClasses=setdiff(classes,classesSmall);

evidence=evidenceGenerator.getEvidenceForImage(data,imageNr,baseClasses);

distance=evidenceGenerator.evidence2Distance(evidence.relEvi);
minDist=zeros(data.getImagesize(imageNr).nrows,data.getImagesize(imageNr).ncols);
minDist(:)=min(distance,[],1);

%% Show image

figure()
subplot(1,2,1)
imshow(data.getColourImage(imageNr));
subplot(1,2,2)
imshow(minDist/max(max(minDist)))

