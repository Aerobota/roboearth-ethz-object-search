classdef LocationEvaluator<Evaluation.Evaluator
    %LOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        baseClasses
    end
    
    methods
        function obj=LocationEvaluator(baseClasses)
            obj.baseClasses=baseClasses;
        end
        
        function result=evaluate(obj,testData,locationLearner)
            targetClass='faucet'
            imageNr=600
            
            probImage=obj.probabilityImage(testData,imageNr,locationLearner,targetClass);
            
            colourImage=testData.getColourImage(imageNr);
            
            figure()
            for f=length(obj.thresholds):-1:1
                mask=uint8(obj.thresholdProbabilityImage(probImage,obj.thresholds(f)));
                imshow(colourImage.*mask(:,:,[1 1 1]))
                result(f)=getframe;
            end
        end
    end
    
    methods(Access='protected')
        function probImage=probabilityImage(obj,data,index,locationLearner,targetClass)
            evidence=locationLearner.evidenceGenerator.getEvidenceForImage(data,index);

            probVec=zeros(size(evidence.relEvi,1),size(evidence.relEvi,2));
            goodObjects=true(size(evidence.relEvi,1),1);

            for o=1:size(evidence.relEvi,1)
                try
                    probVec(o,:)=locationLearner.getProbabilityFromEvidence(squeeze(evidence.relEvi(o,:,:)),evidence.names{o},targetClass);
                catch tmpError
                    if strcmpi(tmpError.identifier,'Learner:missingConnectionData')
                        goodObjects(o)=false;
                    else
                        tmpError.rethrow();
                    end
                end
            end

            probVec=probVec(goodObjects,:);

            probImage=zeros(data.getImagesize(index).nrows,data.getImagesize(index).ncols);
            probImage(:)=prod(probVec,1);
        end
        
        function mask=thresholdProbabilityImage(~,probImage,thresh)
            mask=probImage>thresh*max(max(probImage));
        end
    end
    
end

