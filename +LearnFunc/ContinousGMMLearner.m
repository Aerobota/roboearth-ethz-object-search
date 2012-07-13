classdef ContinousGMMLearner<LearnFunc.ParameterLearner
    properties(Constant)
        maxComponents=3;
    end
    
    methods
        function obj=ContinousGMMLearner(evidenceGenerator)
            obj=obj@LearnFunc.ParameterLearner(evidenceGenerator);
        end
        
        function CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass)
            assert(~isempty(obj.data.(fromClass).(toClass).mean),...
                'Continous2DLearner:getConnectionNodeCPD:missingConnectionData',...
                'The requested classes have too few cooccurences to generate a CPD');
            CPD(1)=gaussian_CPD(network,nodeNumber(1),'mean',obj.data.(fromClass).(toClass).mean,...
                'cov',obj.data.(fromClass).(toClass).cov);
            CPD(2)=tabular_CPD(network,nodeNumber(2),'CPT',obj.data.(fromClass).(toClass).mixCoeff);
        end
    end
    methods(Access='protected')
        function evaluateOrderedSamples(obj,samples,classes)
            for i=1:length(classes)
                for j=1:length(classes)
                    if size(samples{i,j},1)>=obj.minSamples;
                        [tmpMean,tmpCov,tmpCoeff,tmpGMM]=obj.doGMM(samples{i,j});
                        obj.data.(classes{i}).(classes{j}).mean=tmpMean;
                        obj.data.(classes{i}).(classes{j}).cov=tmpCov;
                        obj.data.(classes{i}).(classes{j}).mixCoeff=tmpCoeff;
                        obj.data.(classes{i}).(classes{j}).gmm=tmpGMM;
                        obj.data.(classes{i}).(classes{j}).nrSamples=size(samples{i,j},1);
                    end
                end
            end
        end
        function [outMean,outCov,outCoeff,gmm]=doGMM(obj,samples)
            randomIndices=randperm(size(samples,1));
            split=ceil(length(randomIndices)/3);
            test={samples(randomIndices(1:split),:),...
                samples(randomIndices(split+1:2*split),:),...
                samples(randomIndices(2*split+1:end),:)};
            train={[samples(randomIndices(split+1:2*split),:);samples(randomIndices(2*split+1:end),:)],...
                [samples(randomIndices(1:split),:);samples(randomIndices(2*split+1:end),:)],...
                [samples(randomIndices(1:split),:);samples(randomIndices(split+1:2*split),:)]};
            score=zeros(obj.maxComponents,1);
            for k=1:obj.maxComponents
                for s=1:length(train)
                    score(k)=score(k)+obj.evaluateModelComplexity(train{s},test{s},k);
                end
            end
            
            [~,kOpt]=min(score);
            try
                gmm=gmdistribution.fit(samples,kOpt);
            catch
                outMean=[];
                outCov=[];
                outCoeff=[];
                gmm=[];
                return
            end
            outMean=gmm.mu';
            outCov=gmm.Sigma;
            outCoeff=gmm.PComponents;
        end
    end
    methods(Static,Access='protected')    
        function score=evaluateModelComplexity(trainSet,testSet,k)
            warning('off','stats:gmdistribution:FailedToConverge')
            try
                gmm=gmdistribution.fit(trainSet,k);
                [~,NLogN]=gmm.posterior(testSet);
            catch
                score=inf;
                return
            end
            [n,d]=size(testSet);
            score=2*NLogN+(k*d^2/2+1.5*k*d+k-1)*log(n);
        end
    end
end