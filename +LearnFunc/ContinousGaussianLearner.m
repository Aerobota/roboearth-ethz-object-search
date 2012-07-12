classdef ContinousGaussianLearner<LearnFunc.ParameterLearner    
    methods
        function obj=ContinousGaussianLearner(evidenceGenerator)
            obj=obj@LearnFunc.ParameterLearner(evidenceGenerator);
%             for c=1:length(obj.classes)
%                 for o=1:length(obj.classes)
%                     obj.data.(obj.classes{c}).(obj.classes{o}).mean=[];
%                     obj.data.(obj.classes{c}).(obj.classes{o}).cov=[];
%                 end
%             end
        end
        
        function CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass)
            assert(~isempty(obj.data.(fromClass).(toClass).mean),...
                'Continous2DLearner:getConnectionNodeCPD:missingConnectionData',...
                'The requested classes have too few cooccurences to generate a CPD');
            CPD=gaussian_CPD(network,nodeNumber,'mean',obj.data.(fromClass).(toClass).mean,...
                'cov',obj.data.(fromClass).(toClass).cov);
        end
    end
    methods(Access='protected')
        function evaluateOrderedSamples(obj,samples,classes)
            for i=1:length(classes)
                for j=1:length(classes)
                    if size(samples{i,j},1)>=obj.minSamples;
                        tmpMean=mean(samples{i,j});
                        tmpCov=cov(samples{i,j});
                        obj.data.(classes{i}).(classes{j}).mean=tmpMean';
                        obj.data.(classes{i}).(classes{j}).cov=tmpCov;
                        obj.data.(classes{i}).(classes{j}).nrSamples=size(samples{i,j},1);
                    end
                end
            end
        end
    end
end