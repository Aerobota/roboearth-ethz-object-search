dataPath='Dataset/Sun09_clean';
il=DataHandlers.SunLoader(dataPath);
im=il.getData(il.gtTrain);

ll=LearnFunc.ContinousZGMMLearner({il.objects.name},[il.objects.height]);
tic
ll.learnLocations(im);
learnTime=toc 


listCov=[];
names=fieldnames(ll.data);
N=length(names);
for i=1:N
    for j=1:N
        listCov=[listCov;ll.data.(names{i}).(names{j}).cov(:)];
    end
end

hist(listCov)
thresh=quantile(listCov,0.1);
sumCandidates=0;
%candidate for connection chooser
for i=1:N
    for j=i:N
        if any(ll.data.(names{i}).(names{j}).cov(:)<thresh)
            disp(names([i j])');
            sumCandidates=sumCandidates+1;
        end
    end
end

disp(sumCandidates)