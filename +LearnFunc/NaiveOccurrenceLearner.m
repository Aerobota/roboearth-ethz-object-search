classdef NaiveOccurrenceLearner<LearnFunc.OccurrenceLearner
    %NAIVEOCCURRENCELEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=NaiveOccurrenceLearner(evidenceGenerator)
            obj=obj@LearnFunc.OccurrenceLearner(evidenceGenerator);
        end
        
        function learn(obj,data)
            % get classes and indices of small classes
            classes=data.getClassNames();
            smallIndex=data.className2Index(data.getSmallClassNames());
            largeClassNames=data.getLargeClassNames();
            parentIndices=data.className2Index(largeClassNames);
            
            % for every small class compute 2nd order probability
            for cs=smallIndex
                cp=obj.evidenceGenerator.getEvidence(data,cs,1:length(data),'all');
                cp=cp(:,:,parentIndices);
                boolCP=zeros([2 size(cp,2) size(cp,3)]);
                boolCP(1,:)=cp(1,:);
                boolCP(2,:)=sum(cp(2:end,:),1);
                obj.model.(classes{cs}).parents=largeClassNames;
                obj.model.(classes{cs}).condProb=boolCP./repmat(sum(boolCP,2),[1 size(boolCP,2) 1]);
                obj.model.(classes{cs}).margP=sum(boolCP(:,:,1),2);
                obj.model.(classes{cs}).margP=obj.model.(classes{cs}).margP/sum(obj.model.(classes{cs}).margP);
               
            end
        end
        
        function result=calculateStatistics(obj,testData,occEval)
            myNames=obj.getLearnedClasses();
            
            for i=length(myNames):-1:1
                searchIndicesSmall=testData.className2Index(myNames(i));
                searchIndicesLarge=testData.className2Index(obj.model.(myNames{i}).parents);
                
                evidenceAll=obj.evidenceGenerator.getCBins(testData);
                evidenceSmall=evidenceAll(searchIndicesSmall,:);
                evidenceLarge=evidenceAll(searchIndicesLarge,:);
                
                evidenceSmall(evidenceSmall>1)=1;
                
                for c=size(evidenceLarge,1):-1:1
                    factorCollection(:,c,:)=permute(obj.model.(myNames{i}).condProb(:,evidenceLarge(c,:)+1,c),[1 3 2]);
                end
                
                decisionInput.condProb=squeeze(prod(factorCollection,2)).*...
                    obj.model.(myNames{i}).margP(:,ones(length(evidenceSmall),1));
                
                decisionInput.condProb=decisionInput.condProb./repmat(sum(decisionInput.condProb,1),[2 1]);
                
                decision=occEval.decisionImpl(decisionInput);
                
                result.tp(:,i)=sum(repmat(evidenceSmall,[size(decision,1) 1]).*(decision==2),2);
                result.fp(:,i)=sum(repmat(~evidenceSmall,[size(decision,1) 1]).*(decision==2),2);
                result.pos(1,i)=sum(evidenceSmall);
                result.neg(1,i)=length(evidenceSmall)-result.pos(1,i);
            end
        end
    end
end

