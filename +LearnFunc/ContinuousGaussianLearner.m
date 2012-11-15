classdef ContinuousGaussianLearner<LearnFunc.LocationLearner
    %CONTINUOUSGAUSSIANLEARNER Models relative location as a gaussian
    %   This method a used to learn a gaussian model of the distribution of
    %   relative locations between object pairs.
    methods
        function obj=ContinuousGaussianLearner(evidenceGenerator)
            obj=obj@LearnFunc.LocationLearner(evidenceGenerator);
        end
        
        function prob=getProbabilityFromEvidence(obj,evidence,fromClass,toClass)
            prob=mvnpdf(evidence,obj.model.(fromClass).(toClass).mean,obj.model.(fromClass).(toClass).cov);
        end
        
        function learn(obj,data)
            % samples is a cell array with relative locations for all
            % combinations of classes.
            samples=obj.evidenceGenerator.getEvidence(data);
            classes=data.getClassNames();
            for i=1:length(classes)
                for j=1:length(classes)
                    % Check if enough samples are available
                    if size(samples{i,j},1)>=obj.minSamples;
                        % Save the mean, covariance and sample count
                        obj.model.(classes{i}).(classes{j}).mean=mean(samples{i,j});
                        obj.model.(classes{i}).(classes{j}).cov=cov(samples{i,j});
                        obj.model.(classes{i}).(classes{j}).nrSamples=size(samples{i,j},1);
                    end
                end
            end
        end
    end
end