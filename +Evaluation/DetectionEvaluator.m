classdef DetectionEvaluator
    %DETECTIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        confidencePoints%=linspace(0,0.99,30);
    end
    
    methods
        function obj=DetectionEvaluator(confidencePoints)
            obj.confidencePoints=confidencePoints;
        end
        
        function output=generatePrecisionRecallCurve(obj,detTestData,gtTestData)
            confidence=obj.generateConfidence(detTestData);
            output=struct('recal',[],'precision',[],'fpRate',[],'tpRate',[]);
            for c=1:length(obj.confidencePoints)
                disp(['running with confidence ' num2str(obj.confidencePoints(c))])
                truePositives=0;
                nGTObj=0;
                falsePositives=0;
                parfor i=1:length(gtTestData)
                    disp(['scanning image ' num2str(i)])
                    goodDetections=confidence{i}>obj.confidencePoints(c);
                    nGTObj=nGTObj+length(gtTestData.getObject(i));
                    detObjects=detTestData.getObject(i);
                    nTP=sum([detObjects(goodDetections).overlap]>=0.5);
                    truePositives=truePositives+nTP;
                    nFP=sum(goodDetections)-nTP;
                    falsePositives=falsePositives+nFP;
                end
                output.recal(end+1)=truePositives/nGTObj;
                output.precision(end+1)=truePositives/(truePositives+falsePositives);
                output.fpRate(end+1)=falsePositives/nGTObj;
                output.tpRate(end+1)=truePositives/nGTObj;
            end
        end
    end
    methods(Abstract,Access='protected')
        confidence=generateConfidence(obj,detTestData)
    end
end

