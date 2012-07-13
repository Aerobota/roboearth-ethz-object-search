classdef OccurrenceEvaluator
    %OCCURRENCEEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        evidenceGenerator
    end
    
    properties(Constant)
        thresholds=linspace(0,1,200)';
    end
    
    methods
        function obj=OccurrenceEvaluator(evidenceGenerator)
            obj.evidenceGenerator=evidenceGenerator;
        end
        
        function result=evaluate(obj,testData,dependencies)
            [tpFull,fpFull,posFull,negFull]=obj.calculateStatistics(testData,dependencies,'full');
            [tpBase,fpBase,posBase,negBase]=obj.calculateStatistics(testData,dependencies,'baseline');
            myNames=fieldnames(dependencies);

            tmpBaseline=Evaluation.OccurrenceEvaluationData(myNames,...
                sum(tpBase,2),sum(fpBase,2),sum(posBase,2),sum(negBase,2));
            
            result.perClass=Evaluation.OccurrenceEvaluationData(myNames,...
                tpFull,fpFull,posFull,negFull,tmpBaseline);
            
            result.cummulative=Evaluation.OccurrenceEvaluationData(myNames,...
                sum(tpFull,2),sum(fpFull,2),sum(posFull,2),sum(negFull,2),tmpBaseline);
        end
    end
    
    methods(Access='protected',Abstract)
        decisions=decisionImpl(obj,myDependencies)
    end
    
    methods(Access='protected')
        function [truePositives,falsePositives,positives,negatives]=...
                calculateStatistics(obj,testData,dependencies,mode)
            
            if strcmpi(mode,'baseline')
                calcBaseline=true;
            else
                calcBaseline=false;
            end
            
            myNames=fieldnames(dependencies);
            
            truePositives=[];
            falsePositives=[];
            positives=[];
            negatives=[];
            
            for i=length(myNames):-1:1
                if calcBaseline
                    searchIndices=testData.className2Index(myNames{i});
                else
                    searchIndices=testData.className2Index([myNames(i) dependencies.(myNames{i}).parents]);
                end
                
                evidence=obj.evidenceGenerator.getEvidence(testData,searchIndices,1:length(testData),'single');
                tmpSize=size(evidence);
                boolEvidence=zeros([2 tmpSize(2:end)]);
                boolEvidence(1,:)=evidence(1,:);
                boolEvidence(2,:)=sum(evidence(2:end,:),1);
                
                if calcBaseline
                    decisions=obj.decisionBaseline(dependencies.(myNames{i}).margP);
                else
                    decisions=obj.decisionImpl(dependencies.(myNames{i}));
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

