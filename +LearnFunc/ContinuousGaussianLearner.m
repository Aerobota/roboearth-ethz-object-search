classdef ContinuousGaussianLearner<LearnFunc.ParameterLearner    
    methods
        function obj=ContinuousGaussianLearner(evidenceGenerator)
            obj=obj@LearnFunc.ParameterLearner(evidenceGenerator);
        end
        
        function CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass)
            assert(isfield(obj.data.(fromClass),toClass),... %~isempty(obj.data.(fromClass).(toClass).mean)
                'ParameterLearner:missingConnectionData',...
                'The requested classes have too few cooccurences to generate a CPD');
            CPD=gaussian_CPD(network,nodeNumber,'mean',obj.data.(fromClass).(toClass).mean,...
                'cov',obj.data.(fromClass).(toClass).cov);
        end
        
        function prob=getProbabilityFromEvidence(obj,evidence,fromClass,toClass)
            assert(isfield(obj.data.(fromClass),toClass),... %~isempty(obj.data.(fromClass).(toClass).mean)
                'ParameterLearner:missingConnectionData',...
                'The requested classes have too few cooccurences to generate a probability');
            prob=mvnpdf(evidence,obj.data.(fromClass).(toClass).mean,obj.data.(fromClass).(toClass).cov);
        end
    end
    methods(Access='protected')
        function evaluateOrderedSamples(obj,samples,classes)
            for i=1:length(classes)
                for j=1:length(classes)
                    if size(samples{i,j},1)>=obj.minSamples;
                        tmpMean=mean(samples{i,j});
                        tmpCov=cov(samples{i,j});
                        obj.data.(classes{i}).(classes{j}).mean=tmpMean;
                        obj.data.(classes{i}).(classes{j}).cov=tmpCov;
                        obj.data.(classes{i}).(classes{j}).nrSamples=size(samples{i,j},1);
                    end
                end
            end
        end
    end
end