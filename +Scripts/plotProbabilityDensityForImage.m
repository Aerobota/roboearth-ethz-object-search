%% Check loaded model

assert(isa(locLearnCylindricGMM,'LearnFunc.ContinuousGMMLearner'),'Run script computeLocationData first.')

%% Parameters

imageName='img_00084.jpg';
targetClass='book';

outputFileProb='tmpProbImg.png';
outputFileRGB='tmpImg.png';

maxDistance=0.5;
maxCandidatePoints=5;

useGray=false;
colorRes=256;
probAlpha=0.7;

%% Initialisation

Scripts.setPaths

dataCol{1}=DataHandlers.NYUDataStructure(datasetPath,'train');
dataCol{1}.load()

dataCol{2}=DataHandlers.NYUDataStructure(datasetPath,'test');
dataCol{2}.load()

%% Find image

for d=1:length(dataCol)
    for i=1:length(dataCol{d})
        if strcmpi(dataCol{d}.getFilename(i),imageName)==1
            data=dataCol{d};
            imageNumber=i;
        end
    end
end

%% Calculate probability density

probDensity=zeros(data.getImagesize(imageNumber).nrows,data.getImagesize(imageNumber).ncols);
[prob,loc]=Evaluation.LocationEvaluator.probabilityVector(data,imageNumber,locLearnCylindricGMM,{targetClass},'mean');
probDensity(:)=prob.(targetClass);
probDensity=(probDensity-min(probDensity(:)))/(max(probDensity(:)-min(probDensity(:))));

%% Get candidate points

[~,candProb,candPoints]=Evaluation.LocationEvaluator.getCandidatePoints(prob.(targetClass),loc,[],maxDistance);
candPoints2D=data.getCalib(imageNumber)*candPoints;
candPoints2D=round(candPoints2D(1:2,:)./candPoints([3 3],:));
cImg=data.getColourImage(imageNumber);

tmpH=figure();
imshow(cImg)
for i=1:maxCandidatePoints
    % font sizing doesn't work under unix but it does under windows
    text(candPoints2D(2,i),candPoints2D(1,i),num2str(i),'Color','r','FontName','times','FontSize',20,...
        'HorizontalAlignment','Center','BackgroundColor','w','EdgeColor','r')
end

F=getframe();
close(tmpH)

%% Blend probability image
intensityImage=im2double(rgb2gray(cImg));
intensityImage=(intensityImage-min(intensityImage(:)))/(max(intensityImage(:))-min(intensityImage(:)));

if useGray
    probDensity=probAlpha*probDensity+(1-probAlpha)*intensityImage;
else
    probDensity=ind2rgb(round((colorRes-1)*probDensity)+1,jet(colorRes));
    probDensity=probDensity.*(probAlpha*intensityImage(:,:,ones(size(probDensity,3),1))+1-probAlpha);
end

probDensity=(probDensity-min(probDensity(:)))/(max(probDensity(:)-min(probDensity(:))));


%% Save images

imwrite(F.cdata(1:end-1,1:end-1,:),outputFileRGB)
imwrite(probDensity,outputFileProb)

%% Display image

figure()
subplot(1,2,1)
imshow(F.cdata)

subplot(1,2,2)
imshow(probDensity,[min(probDensity(:)) max(probDensity(:))])

%% Clear temporaries

clear('F','cImg','candPoints','candPoints2D','candProb','data','dataset',...
    'datasetPath','i','imageNumber','loc','maxCandidatePoints','maxDistance',...
    'outputFileProb','outputFileRGB','prob','probDensity','sourceFolder',...
    'targetClass','tmpH','probAlpha','intensityImage','dataCol','d','imageName')
