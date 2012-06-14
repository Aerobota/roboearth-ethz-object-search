classdef ContinousZGMMLearner<LearnFunc.LocationLearner
    properties(Constant)
        minSamples=20;
    end
    properties(SetAccess='protected')
        data;
    end
    
    methods
        function obj=ContinousZGMMLearner(classes,heights)
            obj=obj@LearnFunc.LocationLearner(classes);
            for c=1:length(obj.classes)
                obj.data.(obj.classes{c}).height=heights(c);
                for o=1:length(obj.classes)
                    obj.data.(obj.classes{c}).(obj.classes{o}).mean=[];
                    obj.data.(obj.classes{c}).(obj.classes{o}).cov=[];
                end
            end
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
    methods(Static)
        function evidence=getEvidence(image)
            nObj=length(image.annotation.object);
            pos=zeros(2,nObj);
            for o=1:nObj
                pos(:,o)=[mean(image.annotation.object(o).polygon.x/image.annotation.imagesize.ncols);...
                    mean(image.annotation.object(o).polygon.y/image.annotation.imagesize.nrows)];
            end

            evidence(:,:,1)=pos(2*ones(nObj,1),:)-pos(2*ones(nObj,1),:)';
        end
    end
    methods(Access='protected')
        function evaluateOrderedSamples(obj,samples)
            for i=1:length(obj.classes)
                for j=i:length(obj.classes)
                    if size(samples{i,j},1)>=obj.minSamples;
                        [tmpMean,tmpCov,tmpCoeff]=obj.doGMM(samples{i,j});
                        obj.data.(obj.classes{j}).(obj.classes{i}).mean=tmpMean;
                        obj.data.(obj.classes{j}).(obj.classes{i}).cov=tmpCov;
                        obj.data.(obj.classes{j}).(obj.classes{i}).mixCoeff=tmpCoeff;
                        obj.data.(obj.classes{i}).(obj.classes{j}).mean=tmpMean;
                        obj.data.(obj.classes{i}).(obj.classes{j}).cov=tmpCov;
                        obj.data.(obj.classes{i}).(obj.classes{j}).mixCoeff=tmpCoeff;
                    end
                end
            end
        end
        function [outMean,outCov,outCoeff]=doGMM(obj,samples)
            randomIndices=randperm(size(samples,1));
            split=ceil(length(randomIndices)/3);
            test={samples(randomIndices(1:split),:),...
                samples(randomIndices(split+1:2*split),:),...
                samples(randomIndices(2*split+1:end),:)};
            train={[samples(randomIndices(split+1:2*split),:);samples(randomIndices(2*split+1:end),:)],...
                [samples(randomIndices(1:split),:);samples(randomIndices(2*split+1:end),:)],...
                [samples(randomIndices(1:split),:);samples(randomIndices(split+1:2*split),:)]};
            score=zeros(3,1);
            for k=1:length(score)
                for s=1:length(train)
                    score(k)=score(k)+obj.evaluateModelComplexity(train{s},test{s},k);
                end
            end
            
            [~,kOpt]=min(score);
            gmm=gmdistribution.fit(samples,kOpt);
            outMean=gmm.mu';
            outCov=gmm.Sigma;
            outCoeff=gmm.PComponents;
        end
        
        function score=evaluateModelComplexity(obj,trainSet,testSet,modelComplexity)
            warning('off','stats:gmdistribution:FailedToConverge')
            try
                gmm=gmdistribution.fit(trainSet,modelComplexity);
                [~,NLogN]=gmm.posterior(testSet);
            catch
                score=inf;
                return
            end
            d=size(testSet,2);
            score=2*NLogN+(modelComplexity*(d+d^2)-1)*log(size(testSet,1));
        end
    end
end