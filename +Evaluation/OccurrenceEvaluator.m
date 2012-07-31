classdef OccurrenceEvaluator<Evaluation.Evaluator
    %OCCURRENCEEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        evidenceGenerator
    end
    
    properties(Constant)
        thresholds=linspace(0,1,Evaluation.Evaluator.nThresh)';
    end
    
    methods
        function result=evaluate(obj,testData,occurrenceLearner)
            [result.conditioned.tp,result.conditioned.fp,result.conditioned.pos,result.conditioned.neg]=...
                obj.calculateStatistics(testData,occurrenceLearner,'full');
            [result.baseline.tp,result.baseline.fp,result.baseline.pos,result.baseline.neg]=...
                obj.calculateStatistics(testData,occurrenceLearner,'baseline');
            myNames=occurrenceLearner.getLearnedClasses();

%             tmpBaseline=Evaluation.EvaluationData(myNames,...
%                 sum(tpBase,2),sum(fpBase,2),sum(posBase,2),sum(negBase,2));
%             
%             result.perClass=Evaluation.EvaluationData(myNames,...
%                 tpFull,fpFull,posFull,negFull,tmpBaseline);
%             
%             result.cummulative=Evaluation.EvaluationData(myNames,...
%                 sum(tpFull,2),sum(fpFull,2),sum(posFull,2),sum(negFull,2),tmpBaseline);
%             result.baseline.tp=tpBase;
%             result.baseline.fp=fpBase;
%             result.baseline.pos=posBase;
%             result.baseline.neg=negBase;
            result.baseline.names=myNames;
            
%             result.conditioned.tp=tpFull;
%             result.conditioned.fp=fpFull;
%             result.conditioned.pos=posFull;
%             result.conditioned.neg=negFull;
            result.conditioned.names=myNames;
        end
    end
    
    methods(Access='protected',Abstract)
        decisions=decisionImpl(obj,myDependencies)
    end
    
    methods(Access='protected')
        function [truePositives,falsePositives,positives,negatives]=...
                calculateStatistics(obj,testData,occLearner,mode)
            
            if strcmpi(mode,'baseline')
                calcBaseline=true;
            else
                calcBaseline=false;
            end
            
            myNames=occLearner.getLearnedClasses();
            
            truePositives=[];
            falsePositives=[];
            positives=[];
            negatives=[];
            
            for i=length(myNames):-1:1
                if calcBaseline
                    searchIndices=testData.className2Index(myNames{i});
                else
                    searchIndices=testData.className2Index([myNames(i) occLearner.model.(myNames{i}).parents]);
                end
                
                evidence=occLearner.evidenceGenerator.getEvidence(testData,searchIndices,1:length(testData),'single');
                tmpSize=size(evidence);
                boolEvidence=zeros([2 tmpSize(2:end)]);
                boolEvidence(1,:)=evidence(1,:);
                boolEvidence(2,:)=sum(evidence(2:end,:),1);
                
                if calcBaseline
                    decisions=obj.decisionBaseline(occLearner.model.(myNames{i}).margP);
                else
                    decisions=obj.decisionImpl(occLearner.model.(myNames{i}));
                end
                
                neg=repmat(boolEvidence(1,:),[size(decisions,1) 1]);
                pos=repmat(boolEvidence(2,:),[size(decisions,1) 1]);
                
                truePositives(:,i)=sum(pos.*(decisions(:,:)==2),2);
                falsePositives(:,i)=sum(neg.*(decisions(:,:)==2),2);
                positives(1,i)=sum(boolEvidence(2,:),2);
                negatives(1,i)=sum(boolEvidence(1,:),2);
            end
        end
        
        function decisions=decisionBaseline(obj,margP)
            decisions=ones(length(obj.thresholds),1);
            tmpCP=margP(2*ones(length(obj.thresholds),1),:);
            decisions(tmpCP>=obj.thresholds)=2;
        end
    end
end

