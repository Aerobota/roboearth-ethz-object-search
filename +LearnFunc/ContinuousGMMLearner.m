classdef ContinuousGMMLearner<LearnFunc.LocationLearner
    properties(Constant)
        maxComponents=5;
    end
    
    methods
        function obj=ContinuousGMMLearner(evidenceGenerator)
            obj=obj@LearnFunc.LocationLearner(evidenceGenerator);
        end
        
        function prob=getProbabilityFromEvidence(obj,evidence,fromClass,toClass)
            if isvector(evidence)
                if size(evidence,1)==1
                    evidence=evidence';
                end
            end
            prob=obj.model.(fromClass).(toClass).gmm.pdf(evidence);
        end
        
        function learn(obj,data)
            samples=obj.evidenceGenerator.getEvidence(data,'relative');
            classes=data.getClassNames();
            slicedSamples=cell(size(samples,1),1);
            slicedOutput=cell(length(classes),1);
            for i=1:length(slicedSamples)
                slicedSamples{i}=samples(i,:);
            end
            parfor i=1:length(classes)
                for j=1:length(classes)
                    if size(slicedSamples{i}{j},1)>=obj.minSamples;
                        [tmpMean,tmpCov,tmpCoeff,tmpGMM]=LearnFunc.ContinuousGMMLearner.doGMM(slicedSamples{i}{j});
                        if ~isempty(tmpMean)
                            slicedOutput{i}.(classes{j}).mean=tmpMean;
                            slicedOutput{i}.(classes{j}).cov=tmpCov;
                            slicedOutput{i}.(classes{j}).mixCoeff=tmpCoeff;
                            slicedOutput{i}.(classes{j}).gmm=tmpGMM;
                            slicedOutput{i}.(classes{j}).nrSamples=size(slicedSamples{i}{j},1);
                        end
                    end
                end
                disp(['finished with class ' classes{i}])
            end
            for i=1:length(classes)
                obj.model.(classes{i})=slicedOutput{i};
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