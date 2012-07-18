classdef LocationEvaluator<Evaluation.Evaluator
    %LOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
%     properties(SetAccess='protected')
%         baseClasses
%     end
    properties(Constant)
        maxDistance=0.5;
    end
    
    methods(Abstract,Access='protected')
%         [tp,fp,pos,neg]=scoreImage(obj,data,index,probImage,targetClass)
        [tp,fp,pos,neg]=scoreClass(obj,data,locationLearner,targetClass)
    end
    
    methods
%         function obj=LocationEvaluator(baseClasses)
%             obj.baseClasses=baseClasses;
%         end
        
        function result=evaluate(obj,testData,locationLearner)
%             targetClass='faucet'
%             imageNr=600
            classesSmall=testData.getSmallClassNames();
            
            truePos=[];
            falsePos=[];
            positive=[];
            negative=[];
            
            for c=length(classesSmall):-1:1
                [truePos(:,c),falsePos(:,c),positive(1,c),negative(1,c)]=...
                    obj.scoreClass(testData,locationLearner,classesSmall{c});
%                 error('stop')
%                 for i=length(testData):-1:1
%                     probImage=obj.probabilityImage(testData,i,locationLearner,classesSmall{c});
% 
%                     [truePos(:,c,i),falsePos(:,c,i),positive(i,c),negative(i,c)]=...
%                         obj.scoreImage(testData,i,probImage,classesSmall{c});
%                 end
            end
            
%             truePos=sum(truePos,3);
%             falsePos=sum(falsePos,3);
%             positive=sum(positive,1);
%             negative=sum(negative,1);
            
            warning('baseline is just a dummy function')
            tmpBaseline=Evaluation.EvaluationData(classesSmall,...
                [0;sum(positive,2)],[0;sum(negative,2)],sum(positive,2),sum(negative,2));
            
            result.perClass=Evaluation.EvaluationData(classesSmall,...
                truePos,falsePos,positive,negative,tmpBaseline);
            
            result.cummulative=Evaluation.EvaluationData(classesSmall,...
                sum(truePos,2),sum(falsePos,2),sum(positive,2),sum(negative,2),tmpBaseline);
            
%             colourImage=testData.getColourImage(imageNr);
%             
%             figure()
%             for f=length(obj.thresholds):-1:1
%                 mask=uint8(obj.thresholdProbabilityImage(probImage,obj.thresholds(f)));
%                 imshow(colourImage.*mask(:,:,[1 1 1]))
%                 result(f)=getframe;
%             end
        end
    end
    
    methods(Access='protected')
        function probVec=probabilityVector(~,data,index,locationLearner,targetClass)
            evidence=locationLearner.evidenceGenerator.getEvidenceForImage(data,index);

            probVec=zeros(size(evidence.relEvi,1),size(evidence.relEvi,2));
            goodObjects=true(size(evidence.relEvi,1),1);

            for o=1:size(evidence.relEvi,1)
                try
                    probVec(o,:)=locationLearner.getProbabilityFromEvidence(squeeze(evidence.relEvi(o,:,:)),evidence.names{o},targetClass);
                catch tmpError
%                     if strcmpi(tmpError.identifier,'Learner:missingConnectionData')
                    if strcmpi(tmpError.identifier,'MATLAB:nonExistentField')
                        goodObjects(o)=false;
                    else
                        disp(tmpError.identifier)
                        tmpError.rethrow();
                    end
                end
            end

            probVec=prod(probVec(goodObjects,:),1);
% 
%             probImage=zeros(data.getImagesize(index).nrows,data.getImagesize(index).ncols);
%             probImage(:)=prod(probVec,1);
        end
%         
%         function mask=thresholdProbabilityImage(~,probImage,thresh)
%             mask=probImage>thresh*max(max(probImage));
%         end
    end
end

