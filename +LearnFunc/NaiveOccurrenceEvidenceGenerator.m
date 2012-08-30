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
                out=obj.getCBins(data);
                out=out(targetClasses,subsetIndices);
            elseif strcmpi(mode,'all') 
                assert(length(targetClasses)==1,'EvidenceGenerator:badInput',...
                    'In mode ''all'' the targetClasses argument must be a scalar')
                cBins=obj.getCBins(data);
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
                
                if ~isempty(evidenceLarge)
                    for c=size(evidenceLarge,1):-1:1
                        factorCollection(:,c,:)=permute(occLearner.model.(myNames{i}).condProb(:,evidenceLarge(c,:)+1,c),[1 3 2]);
                    end
                else
                    factorCollection=ones([size(occLearner.model.(myNames{i}).margP,1) 1 length(evidenceSmall)]);
                end
                
                decisionInput.condProb=squeeze(prod(factorCollection,2)).*...
                    occLearner.model.(myNames{i}).margP(:,ones(length(evidenceSmall),1));
                
                decisionInput.condProb=decisionInput.condProb./repmat(sum(decisionInput.condProb,1),[2 1]);
                                
                decision=occEval.decisionImpl(decisionInput);
                
                result.tp(:,i)=sum(repmat(evidenceSmall,[size(decision,1) 1]).*(decision==2),2);
                result.fp(:,i)=sum(repmat(~evidenceSmall,[size(decision,1) 1]).*(decision==2),2);
                result.pos(1,i)=sum(evidenceSmall);
                result.neg(1,i)=length(evidenceSmall)-result.pos(1,i);
                
                if isfield(occLearner.model.(myNames{i}),'expectedUtility')
                    result.expectedUtility(1,i)=occLearner.model.(myNames{i}).expectedUtility;
                end
            end
        end
        
        function eu=calculateExpectedUtility(obj,data,targetClasses,decisionSubset,testSubset,valueMatrix)
            nClasses=length(data.getClassNames());
            decMargP=obj.reduceToBool(obj.getMarginalProbabilities(data,1:nClasses,decisionSubset));
            if ~isempty(targetClasses)
                decCondP=obj.reduceToBool(obj.getEvidence(data,targetClasses(1),decisionSubset,'all'));
                decCondP=decCondP./repmat(sum(decCondP,2)+eps,[1 2]);
            end
            
            threshold=(valueMatrix(1,1)-valueMatrix(2,1))/(valueMatrix(1,1)+valueMatrix(2,2)-valueMatrix(2,1)-valueMatrix(1,2));
            
            statesTest=obj.getEvidence(data,1:nClasses,testSubset,'perImage');
            
            for i=nClasses:-1:1
                if ~ismember(i,targetClasses)
                    if isempty(targetClasses)
                        tmpCondProb=decMargP(:,i*ones(size(statesTest,2),1));
                        tmpTargetState=statesTest(i,:);
                    else
                        currentClasses=[targetClasses(2:end) i];
                        for c=length(currentClasses):-1:1
                            factorCollection(:,c,:)=permute(decCondP(:,statesTest(currentClasses(c),:)+1,currentClasses(c)),[1 3 2]);
                        end
                        tmpCondProb=squeeze(prod(factorCollection,2)).*...
                        decMargP(:,ones(size(statesTest,2),1));
                        tmpCondProb=tmpCondProb./repmat(sum(tmpCondProb,1),[2 1]);
                        tmpTargetState=statesTest(targetClasses(1),:);
                    end
                    
                    tmpTargetState=tmpTargetState>0;
                    decisions=tmpCondProb(2,:)>=threshold;
                    eu(1,i)=obj.calculateExpectedUtilityFromProb(tmpTargetState,decisions,valueMatrix);
                end
            end
        end
        
        function [margP,condP]=calculateModelStatistics(obj,data,targetClasses,subset)
            margP=obj.reduceToBool(obj.getMarginalProbabilities(data,targetClasses(1),subset));
            condP=obj.reduceToBool(obj.getEvidence(data,targetClasses(1),subset,'all'));
            condP=condP(:,:,targetClasses(2:end));
            condP=condP./repmat(sum(condP,2)+eps,[1 2]);
        end
    end
    
    methods(Access='protected',Static)
        function eu=calculateExpectedUtilityFromProb(state,decision,valueMatrix)
            eu=mean(valueMatrix(decision+state*size(valueMatrix,1)+1));
        end
    end
end

