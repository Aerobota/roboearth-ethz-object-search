%% parameters

%evidenceGenerator=LearnFunc.VerticalDistanceEvidenceGenerator();
evidenceGenerator=LearnFunc.CylindricEvidenceGenerator();

learnFunction='gmm';
% learnFunction='gaussian';

%% load data
dataPath='Dataset/NYU';
im=DataHandlers.NYUDataStructure(dataPath,DataHandlers.NYUDataStructure.trainSet,DataHandlers.NYUDataStructure.gt);
im.load();

%% learn location parameters
if strcmpi(learnFunction,'gmm')
    ll=LearnFunc.ContinousGMMLearner(evidenceGenerator);
else
	ll=LearnFunc.ContinousGaussianLearner(evidenceGenerator);
end
tic
ll.learnParameters(im);
learnTime=toc 

% %% learn location connectivity
% listCov=[];
% N=length(classes);
% for i=1:N
%     for j=1:N
%         if ~isempty(ll.data.(classes{i}).(classes{j}).cov)
%             listCov=[listCov;Test.decisionCriterion(ll.data.(classes{i}).(classes{j}))];
%         end
%     end
% end
% 
% figure()
% hist(listCov)
% thresh=quantile(listCov,0.01);
% sumCandidates=0;
% adjacency=false(length(classes));
% for i=1:N
%     for j=1:N
%         if ~isempty(ll.data.(classes{i}).(classes{j}).cov)
%             if any(Test.decisionCriterion(ll.data.(classes{i}).(classes{j}))<thresh)
%                 disp([classes{i} ' ' classes{j} ' ' num2str(diag(ll.data.(classes{i}).(classes{j}).cov)')...
%                     ' ' num2str(ll.data.(classes{i}).(classes{j}).nrSamples)])
%                 sumCandidates=sumCandidates+1;
%                 adjacency(i,j)=true;
%             end
%         end
%     end
% end
% 
% disp(sumCandidates)
% 
% %% display connection graph
% view(biograph(adjacency,classes))