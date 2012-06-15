
dataPath='Dataset/Sun09_clean';
il=DataHandlers.SunLoader(dataPath);
im=il.getData(il.gtTrain);

classes={il.objects.name};

%% learn location parameters
%,[il.objects.height]
ll=LearnFunc.ContinousGMMLearner(classes,LearnFunc.VerticalDistanceEvidenceGenerator());
%ll=LearnFunc.ContinousGaussianLearner(classes,LearnFunc.VerticalDistanceEvidenceGenerator());
tic
ll.learnLocations(im);
learnTime=toc 

%% learn location connectivity
listCov=[];
%names=fieldnames(ll.data);
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
%candidate for connection chooser
for i=1:N
    for j=1:N
        if any(ll.data.(classes{i}).(classes{j}).cov(:)<thresh)
            %disp(classes([i j])');
            sumCandidates=sumCandidates+1;
            adjacency(i,j)=true;
        end
    end
end

disp(sumCandidates)

%% display connection graph
view(biograph(adjacency,classes))