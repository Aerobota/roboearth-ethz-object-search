%% Parameters

datasetPath='Dataset/NYU';
imageNr=1;
targetClass='faucet';

%% Init

data=DataHandlers.NYUDataStructure(datasetPath,'test','gt');
data.load();

% if ~isa(ll,'LearnFunc.ParameterLearner') ||...
%         ~isa(evidenceGenerator,'LearnFunc.EvidenceGenerator')
%     Test.testDistance
% end

%% Show image

figure()
imshow(data.getColourImage(imageNr));

%% Load objects

objects=data.getObject(imageNr);
imageSize=data.getImagesize(imageNr);
depthImage=data.getDepthImage(imageNr);

names={objects.name}

classes=data.getClassNames;
classesSmall=classes([1 2 7 9 10 12 14 16 18 22 25 26 32 33 35 36 37 38 39]);

knownObjects=objects(~ismember(names,classesSmall));
knownPos=[knownObjects.pos];

[tmpX,tmpY]=meshgrid(0:size(depthImage,1)-1,0:size(depthImage,2)-1);

searchedPos=[tmpX(:)';tmpY(:)';ones(1,numel(tmpX))];
searchedPos=data.getCalib(imageNr)\searchedPos;
for d=1:3   
    searchedPos(d,:)=searchedPos(d,:).*depthImage(tmpX(:)+1,tmpY(:)+1);
end