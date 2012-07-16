classdef ContinuousGMMLearner<LearnFunc.ParameterLearner
    properties(Constant)
        maxComponents=3;
    end
    
    methods
        function obj=ContinuousGMMLearner(evidenceGenerator)
            obj=obj@LearnFunc.ParameterLearner(evidenceGenerator);
        end
        
        function CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass)
            assert(isfield(obj.data.(fromClass),toClass),... %~isempty(obj.data.(fromClass).(toClass).mean)
                'ParameterLearner:missingConnectionData',...
                'The requested classes have too few cooccurences to generate a CPD');
            CPD(1)=gaussian_CPD(network,nodeNumber(1),'mean',obj.data.(fromClass).(toClass).mean,...
                'cov',obj.data.(fromClass).(toClass).cov);
            CPD(2)=tabular_CPD(network,nodeNumber(2),'CPT',obj.data.(fromClass).(toClass).mixCoeff);
        end
        
        function prob=getProbabilityFromEvidence(obj,evidence,fromClass,toClass)
            assert(isfield(obj.data.(fromClass),toClass),... %~isempty(obj.data.(fromClass).(toClass).gmm)
                'ParameterLearner:missingConnectionData',...
                'The requested classes have too few cooccurences to generate a probability');
            prob=obj.data.(fromClass).(toClass).gmm.pdf(evidence);
%             error('ParameterLearner:notImplemented','This method is not implemented yet');
        end
    end
    methods(Access='protected')
        function evaluateOrderedSamples(obj,samples,classes)
            slicedSamples=cell(size(samples,1),1);
            slicedOutput=cell(length(classes),1);
            for i=1:length(slicedSamples)
                slicedSamples{i}=samples(i,:);
            end
            parfor i=1:length(classes)
                for j=1:length(classes)
                    if size(slicedSamples{i}{j},1)>=LearnFunc.ParameterLearner.minSamples;
                        [tmpMean,tmpCov,tmpCoeff,tmpGMM]=LearnFunc.ContinuousGMMLearner.doGMM(slicedSamples{i}{j});
                        slicedOutput{i}.(classes{j}).mean=tmpMean;
                        slicedOutput{i}.(classes{j}).cov=tmpCov;
                        slicedOutput{i}.(classes{j}).mixCoeff=tmpCoeff;
                        slicedOutput{i}.(classes{j}).gmm=tmpGMM;
                        slicedOutput{i}.(classes{j}).nrSamples=size(slicedSamples{i}{j},1);
                    end
                end
                disp(['finished with class ' classes{i}])
            end
            for i=1:length(classes)
                obj.data.(classes{i})=slicedOutput{i};
            end
        end
    end
    methods(Static,Access='protected')
        function [outMean,outCov,outCoeff,gmm]=doGMM(samples)
            randomIndices=randperm(size(samples,1));
            split=ceil(length(randomIndices)/3);
            test={samples(randomIndices(1:split),:),...
                samples(randomIndices(split+1:2*split),:),...
                samples(randomIndices(2*split+1:end),:)};
            train={[samples(randomIndices(split+1:2*split),:);samples(randomIndices(2*split+1:end),:)],...
                [samples(randomIndices(1:split),:);samples(randomIndices(2*split+1:end),:)],...
                [samples(randomIndices(1:split),:);samples(randomIndices(split+1:2*split),:)]};
            score=zeros(LearnFunc.ContinuousGMMLearner.maxComponents,1);
            for k=1:LearnFunc.ContinuousGMMLearner.maxComponents
                for s=1:length(train)
                    score(k)=score(k)+LearnFunc.ContinuousGMMLearner.evaluateModelComplexity(train{s},test{s},k);
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