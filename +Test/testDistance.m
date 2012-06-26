clear all

%% parameters

%evidenceMethod=@LearnFunc.VerticalDistanceEvidenceGenerator.getRelativeEvidence;
evidenceMethod=@LearnFunc.CylindricEvidenceGenerator.getRelativeEvidence;

learnFunction='gmm';
%learnFunction='gaussian';

%% load data
dataPath='Dataset/NYU';
ilgt=DataHandlers.NYUGTLoader(dataPath);
im=ilgt.getData(ilgt.trainSet);

classes={ilgt.classes.name};

%% learn location parameters
if strcmpi(learnFunction,'gmm')
    ll=LearnFunc.ContinousGMMLearner(classes,evidenceMethod);
else
	ll=LearnFunc.ContinousGaussianLearner(classes,evidenceMethod);
end
tic
ll.learnLocations(im);
learnTime=toc 

%% learn location connectivity
listCov=[];
N=length(classes);
for i=1:N
    for j=1:N
        listCov=[listCov;ll.data.(classes{i}).(classes{j}).cov(:)];
    end
end

figure()
hist(listCov)
thresh=quantile(listCov,0.2);
sumCandidates=0;
adjacency=false(length(classes));
for i=1:N
    for j=1:N
        if any(ll.data.(classes{i}).(classes{j}).cov(:)<thresh)
            sumCandidates=sumCandidates+1;
            adjacency(i,j)=true;
        end
    end
end

disp(sumCandidates)

%% display connection graph
view(biograph(adjacency,classes))