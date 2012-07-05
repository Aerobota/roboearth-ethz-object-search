classdef DetectionEvaluator
    %DETECTIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        confidencePoints=linspace(0,0.9,4);
    end
    
    methods
        function output=generatePrecisionRecallCurve(obj,detTestData,gtTestData)
            confidence=obj.generateConfidenceMatrix(detTestData);
            for c=1:length(obj.confidencePoints)
                disp(['running with confidence ' num2str(obj.confidencePoints(c))])
                truePositives=0;
                nGTObj=0;
                falsePositives=0;
                for i=1:length(gtTestData)
                    disp(['scanning image ' num2str(i)])
                    goodDetections=confidence{i}>obj.confidencePoints(c);
                    nGTObj=nGTObj+length(gtTestData.getObject(i));
                    detObjects=detTestData.getObject(i);
                    nTP=sum(detObjects(goodDetections).overlap>=0.5);
                    truePositives=truePositives+nTP;
                    falsePositives=falsePositives+sum(goodDetections)-nTP;
                end
                output.recal(end+1)=truePositives/nGTObj;
                output.precision(end+1)=truePositives/(truePositives+falsePositives);
            end
        end
    end
    methods(Abstract,Access='protected')
        confidence=generateConfidence(obj,detTestData)
    end
end

