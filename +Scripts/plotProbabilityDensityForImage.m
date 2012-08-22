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

%% Initialisation

Scripts.setPaths

data=DataHandlers.NYUDataStructure(datasetPath,dataset);
data.load()

%% Calculate probability density

probDensity=zeros(data.getImagesize(imageNumber).nrows,data.getImagesize(imageNumber).ncols);
[prob,loc]=Evaluation.LocationEvaluator.probabilityVector(data,imageNumber,locLearnCylindricGMM,{targetClass});
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
    text(candPoints2D(2,i),candPoints2D(1,i),num2str(i),'Color','r','FontName','times','FontSize',20)
end

F=getframe();
close(tmpH)

%% Save images

imwrite(F.cdata,outputFileRGB)
imwrite(probDensity,outputFileProb)

%% Display image

figure()
subplot(1,2,1)
imshow(F.cdata)

subplot(1,2,2)
imshow(probDensity,[min(probDensity(:)) max(probDensity(:))])
