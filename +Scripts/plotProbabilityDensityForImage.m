%% Check loaded model

assert(isa(locLearnCylindricGMM,'LearnFunc.ContinuousGMMLearner'),'Run script computeLocationData first.')

%% Parameters

dataset='test';
imageNumber=2;
targetClass='bottle';

outputFileProb='tmpProbImg.png';
outputFileRGB='tmpImg.png';

maxDistance=0.5;
maxCandidatePoints=5;

probAlpha=0.9;

%% Initialisation

Scripts.setPaths

data=DataHandlers.NYUDataStructure(datasetPath,dataset);
data.load()

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
probDensity=probAlpha*probDensity+(1-probAlpha)*intensityImage;

%% Save images

imwrite(F.cdata,outputFileRGB)
imwrite(probDensity,outputFileProb)

%% Display image

figure()
subplot(1,2,1)
imshow(F.cdata)

subplot(1,2,2)
imshow(probDensity,[min(probDensity(:)) max(probDensity(:))])

%% Clear temporaries

clear('F','cImg','candPoints','candPoints2D','candProb','data','dataset','datasetPath','i','imageNumber','loc','maxCandidatePoints',...
    'maxDistance','outputFileProb','outputFileRGB','prob','probDensity','sourceFolder','targetClass','tmpH')
