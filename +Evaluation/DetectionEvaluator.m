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
                for i=1:length(gtTestData)
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
                    
                    obj.showPerformance(i,detObjects,gtTestData,goodDetections,tmpOverlap,confidence{i});
                    pause
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
        function showPerformance(index,detObjects,gtData,goodDetections,tmpOverlap,confidence)
            figure();
            imshow(gtData.getColourImage(index));
            hold on
            objRecog=detObjects(goodDetections);
            objNRecog=detObjects(~goodDetections);
            conRecog=confidence(goodDetections);
            conNRecog=confidence(~goodDetections);
            
            pGood=objRecog(tmpOverlap>=0.5);
            conGood=conRecog(tmpOverlap>=0.5);
            overGood=tmpOverlap(tmpOverlap>=0.5);
            pBad=objRecog(tmpOverlap<0.5);
            conBad=conRecog(tmpOverlap<0.5);
            overBad=tmpOverlap(tmpOverlap<0.5);
            pCorrect=objNRecog([objNRecog.overlap]>=0.5);
            conCorrect=conNRecog([objNRecog.overlap]>=0.5);
            if ~isempty(pGood)
                Evaluation.DetectionEvaluator.drawPolygon(pGood,overGood,conGood,'g')
            end
            if ~isempty(pBad)
                Evaluation.DetectionEvaluator.drawPolygon(pBad,overBad,conBad,'r')
            end
            if ~isempty(pCorrect)
                Evaluation.DetectionEvaluator.drawPolygon(pCorrect,[pCorrect.overlap],conCorrect,'b')
            end
        end
        
        function drawPolygon(objects,overlaps,confidence,colour)
            poly=[objects.polygon];
            x=[poly.x];
            y=[poly.y];
            plot(y([1:end 1],:),x([1:end 1],:),colour);
            for o=1:length(objects)
                tmpString=[objects(o).name ': ' num2str(overlaps(o)) ',' num2str(confidence(o))];
                text(min(objects(o).polygon.y),min(objects(o).polygon.x),tmpString,'color',colour);
            end
        end
    end
end

