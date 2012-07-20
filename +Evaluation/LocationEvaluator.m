classdef LocationEvaluator<Evaluation.Evaluator
    %LOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        maxDistance=0.5;
    end
    
    methods(Abstract,Access='protected')
        [tp,prob,pos,neg]=scoreClass(obj,data,locationLearner,targetClass)
    end
    
    methods        
        function result=evaluate(obj,testData,locationLearner)
            classesSmall=testData.getSmallClassNames();
            
            truePos=cell(1,length(classesSmall));
%             falsePos=cell(1,length(classesSmall));
            threshold=cell(1,length(classesSmall));
            positive=[];
            negative=[];
            
            parfor c=1:length(classesSmall)
                [truePos{c},threshold{c},positive(1,c),negative(1,c)]=...
                    obj.scoreClass(testData,locationLearner,classesSmall{c});
            end
            
            warning('baseline is just a dummy function')
            tmpBaseline=Evaluation.EvaluationData(classesSmall,...
                [0;sum(positive,2)],[0;sum(negative,2)],sum(positive,2),sum(negative,2));
            
            for c=length(classesSmall):-1:1
                [pcTP(:,c),pcFP(:,c)]=obj.reduceEvidence(truePos{c},threshold{c});
            end
            result.perClass=Evaluation.EvaluationData(classesSmall,...
                pcTP,pcFP,positive,negative,tmpBaseline);
            
            [cumTP,cumFP]=obj.reduceEvidence(vertcat(truePos{:}),vertcat(threshold{:}));
            
            result.cummulative=Evaluation.EvaluationData(classesSmall,...
                cumTP,cumFP,sum(positive,2),sum(negative,2),tmpBaseline);
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
                    if strcmpi(tmpError.identifier,'MATLAB:nonExistentField')
                        goodObjects(o)=false;
                    else
                        disp(tmpError.identifier)
                        tmpError.rethrow();
                    end
                end
            end

            probVec=prod(probVec(goodObjects,:),1);
        end
        
        function [tpSmall,fpSmall]=reduceEvidence(obj,tp,prob)
            if ~isempty(tp)
                [~,permIndex]=sort(prob,'descend');

                tpSort=tp(permIndex);
                tpSum=cumsum(tpSort);
                fpSum=cumsum(~tpSort);

                selector=[true (tpSort(2:end-1) & ~tpSort(3:end)) true];

                tp=tpSum(selector);
                fp=fpSum(selector);

                tpSmall=tp(round(linspace(1,length(tp),obj.nThresh)));
                fpSmall=fp(round(linspace(1,length(fp),obj.nThresh)));
            else
                tpSmall=zeros(obj.nThresh,1);
                fpSmall=zeros(obj.nThresh,1);
            end
        end
    end
end

