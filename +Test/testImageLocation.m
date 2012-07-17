%% Parameters

imageNr=1;
targetClass='bottle';
doAnimation=false;

%% Init

if exist('ll','var')~=1 || ~isa(ll,'LearnFunc.Learner')
    error('Need to run Test.testDistance first')
end

data=DataHandlers.NYUDataStructure(datasetPath,'test');
data.load();

%% Get evidence

classes=data.getClassNames;
classesSmall=classes([1 2 7 9 10 12 14 16 18 22 25 26 32 33 35 36 37 38 39]);
baseClasses=setdiff(classes,classesSmall);

evidence=ll.evidenceGenerator.getEvidenceForImage(data,imageNr,baseClasses);

distance=ll.evidenceGenerator.evidence2Distance(evidence.relEvi);
minDist=zeros(data.getImagesize(imageNr).nrows,data.getImagesize(imageNr).ncols);
minDist(:)=min(distance,[],1);

probVec=ones(size(evidence.relEvi,1),size(evidence.relEvi,2));
goodObjects=true(size(evidence.relEvi,1),1);

for o=1:size(evidence.relEvi,1)
    try
        probVec(o,:)=ll.getProbabilityFromEvidence(squeeze(evidence.relEvi(o,:,:)),evidence.names{o},targetClass);
    catch tmpError
        if strcmpi(tmpError.identifier,'Learner:missingConnectionData')
            goodObjects(o)=false;
        else
            tmpError.rethrow();
        end
    end
end

probVec=probVec(goodObjects,:);

probMat=zeros(data.getImagesize(imageNr).nrows,data.getImagesize(imageNr).ncols);
tmpProbMat=probMat;
probMat(:)=prod(probVec,1);

gtLocation=false(size(probMat));
objects=data.getObject(imageNr);
objects=objects(ismember({objects.name},targetClass));
for o=1:length(objects)
    gtLocation=gtLocation | poly2mask(objects(o).polygon.y,objects(o).polygon.x,size(gtLocation,1),size(gtLocation,2));
end

%% Show image

figure()
subplot(2,2,1)
imshow(data.getColourImage(imageNr));
title('original image')
subplot(2,2,2)
imshow(minDist,[min(min(minDist)) max(max(minDist))])
title('minimal distance to next object')
subplot(2,2,3)
imshow(probMat,[min(min(probMat)) max(max(probMat))])
title(['probability of finding a ' targetClass])
subplot(2,2,4)
imshow(data.getColourImage(imageNr).*uint8(gtLocation(:,:,[1 1 1])))
title(['groundtruth location for all ' targetClass])

if doAnimation
    figure()
    for f=size(probVec,1):-1:1
        tmpProbMat(:)=probVec(f,:);
        imshow(tmpProbMat,[min(min(tmpProbMat)) max(max(tmpProbMat))])
        text(4,4,evidence.names{f},'BackgroundColor','w','VerticalAlignment','top','margin',3)
        m(f)=getframe;
    end
    movie(m,3,1)
end