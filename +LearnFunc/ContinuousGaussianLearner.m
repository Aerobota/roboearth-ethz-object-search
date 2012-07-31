classdef ContinuousGaussianLearner<LearnFunc.Learner    
    methods
        function obj=ContinuousGaussianLearner(evidenceGenerator)
            obj=obj@LearnFunc.Learner(evidenceGenerator);
        end
        
        function prob=getProbabilityFromEvidence(obj,evidence,fromClass,toClass)
            prob=mvnpdf(evidence,obj.data.(fromClass).(toClass).mean,obj.data.(fromClass).(toClass).cov);
        end
        
        function learn(obj,data)
            samples=obj.evidenceGenerator.getEvidence(data,'relative');
            obj.model.samples=samples;
            classes=data.getClassNames();
            for i=1:length(classes)
                for j=1:length(classes)
                    if size(samples{i,j},1)>=obj.minSamples;
                        tmpMean=mean(samples{i,j});
                        tmpCov=cov(samples{i,j});
                        obj.model.(classes{i}).(classes{j}).mean=tmpMean;
                        obj.model.(classes{i}).(classes{j}).cov=tmpCov;
                        obj.model.(classes{i}).(classes{j}).nrSamples=size(samples{i,j},1);
                    end
                end
            end
        end
    end
end