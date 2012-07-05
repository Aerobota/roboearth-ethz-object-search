classdef BaselineEvaluator<Evaluation.DetectionEvaluator
    %BASELINEEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=BaselineEvaluator(confidencPoints)
            obj=obj@Evaluation.DetectionEvaluator(confidencPoints);
        end
    end
    methods(Access='protected')
        function confidence=generateConfidence(~,detTestData)
            nImgs=length(detTestData);
            confidence=cell(1,nImgs);
            minConfidence=inf;
            maxConfidence=-inf;
            parfor i=1:nImgs
                disp(['scanning image ' num2str(i)])
                confidence{i}=[detTestData.getObject(i).score];
                minConfidence=min(minConfidence,min(confidence{i}));
                maxConfidence=max(maxConfidence,max(confidence{i}));
            end
            scale=maxConfidence-minConfidence;
            for i=1:nImgs
                confidence{i}=(confidence{i}-minConfidence)/scale;
            end
        end
    end
    
end

