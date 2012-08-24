%% Check loaded model

assert(isa(locLearnCylindricGMM,'LearnFunc.ContinuousGMMLearner'),'Run script computeLocationData first.')

%% Parameters

dataset='test';
imageNumbers=1:20;
targetClass='bottle';

%% Initialisation

Scripts.setPaths

data=DataHandlers.NYUDataStructure(datasetPath,dataset);
data.load()

%% Calculate probability density
output=zeros(0,2);
for i=1:length(imageNumbers)
    probDensity=zeros(data.getImagesize(imageNumbers(i)).nrows,data.getImagesize(imageNumbers(i)).ncols);
    [prob,loc]=Evaluation.LocationEvaluator.probabilityVector(data,imageNumbers(i),locLearnCylindricGMM,{targetClass});
    probDensity(:)=prob.(targetClass);
    output(end+1,:)=[max(probDensity(:)) sum(probDensity(:))];
end

figure()
loglog(output(:,1),output(:,2),'*')
figure()
semilogx(output(:,1),output(:,1)./output(:,2),'*')