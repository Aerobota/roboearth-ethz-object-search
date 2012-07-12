classdef OccurrenceEvaluator
    %OCCURRENCEEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        evidenceGenerator
    end
    
    methods
        function obj=OccurrenceEvaluator(evidenceGenerator)
            obj.evidenceGenerator=evidenceGenerator;
        end
        
        function result=evaluateROC(obj,testData,dependencies)
            myNames=fieldnames(dependencies);
            
            truePositives=[];
            falsePositives=[];
            positives=[];
            negatives=[];
            
            for i=length(myNames):-1:1
                searchIndices=testData.className2Index([myNames(i) dependencies.(myNames{i}).parents]);
                evidence=obj.evidenceGenerator.getEvidence(testData,searchIndices,1:length(testData),'single');
                tmpSize=size(evidence);
                boolEvidence=zeros([2 tmpSize(2:end)]);
                boolEvidence(1,:)=evidence(1,:);
                boolEvidence(2,:)=sum(evidence(2:end,:),1);
                decisions=obj.decisionImpl(dependencies.(myNames{i}));
                
                neg=repmat(boolEvidence(1,:),[size(decisions,1) 1]);
                pos=repmat(boolEvidence(2,:),[size(decisions,1) 1]);
                
%                 disp([size(neg) size(pos) size(decisions(:,:)==2)]);
%                 disp(pos.*(decisions(:,:)==2))
                
                truePositives(:,i)=sum(pos.*(decisions(:,:)==2),2);
                falsePositives(:,i)=sum(neg.*(decisions(:,:)==2),2);
                positives(1,i)=sum(boolEvidence(2,:),2);
                negatives(1,i)=sum(boolEvidence(1,:),2);
                
%                 tpRate.(myNames{i})=truePositives(:,i)/positives(1,i);
%                 fpRate.(myNames{i})=falsePositives(:,i)/negatives(1,i);
            end
            result.perClass.names=myNames;
            result.perClass.tpRate=truePositives./positives(ones(size(truePositives,1),1),:);
            result.perClass.fpRate=falsePositives./negatives(ones(size(falsePositives,1),1),:);
            
            result.cummulative.tpRate=sum(truePositives,2)/sum(positives,2);
            result.cummulative.fpRate=sum(falsePositives,2)/sum(negatives,2);
        end
    end
    
    methods(Access='protected',Abstract)
        decisions=decisionImpl(obj,myDependencies)
    end
    
end

