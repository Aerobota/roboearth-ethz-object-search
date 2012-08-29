classdef NaiveOccurrenceEvidenceGenerator<LearnFunc.OccurrenceEvidenceGenerator
    %NAIVEOCCURRENCEEVIDENCEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=NaiveOccurrenceEvidenceGenerator(states)
            obj=obj@LearnFunc.OccurrenceEvidenceGenerator(states);
        end
        
        function out=getEvidence(obj,data,targetClasses,subsetIndices,mode)
            if strcmpi(mode,'perImage')
                out=DataHandlers.StateBinsBuffer.getCBins(data,obj);
                out=out(targetClasses,subsetIndices);
            elseif strcmpi(mode,'all') 
                assert(length(targetClasses)==1,'EvidenceGenerator:badInput',...
                    'In mode ''all'' the targetClasses argument must be a scalar')
                cBins=DataHandlers.StateBinsBuffer.getCBins(data,obj);
                out=zeros(length(obj.states),length(obj.states),length(data.getClassNames()));
                
                k=[1;size(out,1);size(out,1)*size(out,2)];
                
                for s=subsetIndices
                    v=[cBins(targetClasses*ones(size(out,3),1),s) cBins(:,s) (0:size(out,3)-1)'];
                    linInd=v*k+1;
                    out(linInd)=out(linInd)+1;
                end
            else
                error('EvidenceGenerator:badInput','The mode argument has to be ''all'' or ''perImage''.');
            end
        end
        
        function result=calculateStatistics(obj,testData,occLearner,occEval)
            myNames=occLearner.getLearnedClasses();
            
            for i=length(myNames):-1:1
                searchIndicesSmall=testData.className2Index(myNames(i));
                searchIndicesLarge=testData.className2Index(occLearner.model.(myNames{i}).parents);
                
                evidenceAll=obj.getEvidence(testData,[searchIndicesSmall,searchIndicesLarge],1:length(testData),'perImage');
                evidenceSmall=evidenceAll(1,:);
                evidenceLarge=evidenceAll(2:end,:);
                
                evidenceSmall(evidenceSmall>1)=1;
                
                for c=size(evidenceLarge,1):-1:1
                    factorCollection(:,c,:)=permute(occLearner.model.(myNames{i}).condProb(:,evidenceLarge(c,:)+1,c),[1 3 2]);
                end
                
                decisionInput.condProb=squeeze(prod(factorCollection,2)).*...
                    occLearner.model.(myNames{i}).margP(:,ones(length(evidenceSmall),1));
                
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

