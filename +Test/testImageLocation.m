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



%% Load objects

objects=data.getObject(imageNr);
imageSize=data.getImagesize(imageNr);
depthImage=data.getDepthImage(imageNr);
colourImage=data.getColourImage(imageNr);

names={objects.name}

classes=data.getClassNames;
classesSmall=classes([1 2 7 9 10 12 14 16 18 22 25 26 32 33 35 36 37 38 39]);

knownObjects=objects(~ismember(names,classesSmall));
knownPos=[knownObjects.pos];

[tmpX,tmpY]=meshgrid((0:size(depthImage,1)-1)',0:size(depthImage,2)-1);
tmpX=tmpX';
tmpY=tmpY';
% tmpX=uint16(tmpX);
% tmpY=uint16(tmpY);

searchedPos=[tmpX(:)';tmpY(:)';ones(1,numel(tmpX))];
searchedPos=data.getCalib(imageNr)\searchedPos;
% tmptmp=depthImage(tmpX(:)'+1,tmpY(:)'+1);

all(searchedPos(3,:)==1)

for d=1:3
    for c=1:size(tmpX,2)
        searchedPos(d,(c-1)*size(tmpX,1)+1:c*size(tmpX,1))=searchedPos(d,(c-1)*size(tmpX,1)+1:c*size(tmpX,1)).*...
            depthImage(tmpX(:,c)'+1+tmpY(:,c)'*size(tmpX,1));
    end
end

outImg=depthImage;
outImg(tmpX(:)'+1+tmpY(:)'*size(tmpX,1))=searchedPos(3,:);

figure()
scatter3(searchedPos(1,:),searchedPos(2,:),searchedPos(3,:),5,colourImage(1:size(colourImage,1)*size(colourImage,2)))
xlabel('x')
ylabel('y')
zlabel('depth')

%% Show image

figure()
imshow(data.getColourImage(imageNr));