classdef DetectionEvaluator
    %DETECTIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        confidencePoints
    end
    
    methods
        function obj=DetectionEvaluator(confidencePoints)
            obj.confidencePoints=confidencePoints;
        end
        
        function output=evaluateDetectionPerformance(obj,detTestData,gtTestData)
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
                    
                    gtObjects=gtTestData.getObject(i);
                    detObjects=detTestData.getObject(i);
                    recogObjects=detObjects(goodDetections);
                    
                    tmpOverlap=detTestData.computeOverlap(recogObjects,gtObjects,'exclusive');
                    
                    nGTObj=nGTObj+length(gtObjects);
                    nTP=sum(tmpOverlap>=0.5);
                    nFP=sum(goodDetections)-nTP;
                    truePositives=truePositives+nTP;
                    falsePositives=falsePositives+nFP;
                    
%                     obj.showPerformance(i,detObjects,gtTestData,goodDetections);
%                     pause
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
    methods(Static)
        function showPerformance(index,detObjects,gtData,goodDetections)
            figure()
            imshow(gtData.getColourImage(index));
            hold on
            objRecog=detObjects(goodDetections);
            objNRecog=detObjects(~goodDetections);
            
            pGood=[objRecog([objRecog.overlap]>=0.5).polygon];
            pBad=[objRecog([objRecog.overlap]<0.5).polygon];
            pCorrect=[objNRecog([objNRecog.overlap]>=0.5).polygon];
            if ~isempty(pGood)
                plot([pGood.y],[pGood.x],'-g')
            end
            if ~isempty(pBad)
                plot([pBad.y],[pBad.x],'-r')
            end
            if ~isempty(pCorrect)
                plot([pCorrect.y],[pCorrect.x],'-b')
            end
        end
    end
end

