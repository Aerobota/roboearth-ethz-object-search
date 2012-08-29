classdef ConditionalOccurrenceEvidenceGenerator<LearnFunc.OccurrenceEvidenceGenerator
    methods
        function obj=ConditionalOccurrenceEvidenceGenerator(states)
            obj=obj@LearnFunc.OccurrenceEvidenceGenerator(states);
        end
        
        function cop=getEvidence(obj,data,targetClasses,subsetIndices,mode)
            if strcmpi(mode,'all')
                getAllClasses=true;
            elseif strcmpi(mode,'single')
                getAllClasses=false;
            else
                error('EvidenceGenerator:badInput','The mode argument has to be ''all'' or ''single''.');
            end
            
            % get state bin indices
            allCBins=obj.getCBins(data);
            
            if getAllClasses
                nClasses=length(data.getClassNames());
                cop=zeros([repmat(length(obj.states),[1 length(targetClasses)+1]) nClasses]);
                extender=repmat(1:length(targetClasses),[nClasses 1]);
                s=size(cop);
            else
                if length(targetClasses)==1
                    cop=zeros(length(obj.states),1);
                    s=length(cop);
                else
                    cop=zeros(repmat(length(obj.states),[1 length(targetClasses)]));
                    s=size(cop);
                end
            end

            k=cumprod([1 s(1:end-1)])';

            for s=subsetIndices
                if getAllClasses
                    cBins=allCBins(:,s);

                    cBinsTarget=cBins(targetClasses);
                    v=[cBinsTarget(extender) cBins (0:nClasses-1)'];
                else
                    v=allCBins(targetClasses,s)';
                end
                linInd=1+v*k;
                cop(linInd)=cop(linInd)+1;
            end
        end
        
        function result=calculateStatistics(obj,testData,occLearner,occEval)
            myNames=occLearner.getLearnedClasses();
            
            for i=length(myNames):-1:1
                searchIndices=testData.className2Index([myNames(i) occLearner.model.(myNames{i}).parents]);
                
                evidence=obj.getEvidence(testData,searchIndices,1:length(testData),'single');
                tmpSize=size(evidence);
                boolEvidence=zeros([2 tmpSize(2:end)]);
                boolEvidence(1,:)=evidence(1,:);
                boolEvidence(2,:)=sum(evidence(2:end,:),1);
                
                decisions=occEval.decisionImpl(occLearner.model.(myNames{i}));
                
                neg=repmat(boolEvidence(1,:),[size(decisions,1) 1]);
                pos=repmat(boolEvidence(2,:),[size(decisions,1) 1]);
                
                result.tp(:,i)=sum(pos.*(decisions(:,:)==2),2);
                result.fp(:,i)=sum(neg.*(decisions(:,:)==2),2);
                result.pos(1,i)=sum(boolEvidence(2,:),2);
                result.neg(1,i)=sum(boolEvidence(1,:),2);
                
                result.expectedUtility(1,i)=occLearner.model.(myNames{i}).expectedUtility;
            end
        end
        
        function eu=calculateExpectedUtility(obj,data,targetClasses,decisionSubset,testSubset,valueMatrix)
            copDec=obj.reduceToBool(obj.getEvidence(data,targetClasses,decisionSubset,'all'));
            optDec=obj.computeCostOptimalDecisions(copDec(:,:),valueMatrix);
            copTest=obj.reduceToBool(obj.getEvidence(data,targetClasses,testSubset,'all'));
            euCond=obj.computeExpectedUtilityConditional(copTest(:,:),optDec,valueMatrix);
            eu=sum(reshape(euCond/(sum(copTest(:))/size(copTest,ndims(copTest))),...
                [numel(euCond)/size(copTest,ndims(copTest)) size(copTest,ndims(copTest))]),1);
        end
        
        function [margP,condP]=calculateModelStatistics(obj,data,targetClasses)
            margP=obj.reduceToBool(obj.getEvidence(data,targetClasses(1),1:length(data),'single'));
            margP=margP/sum(margP);
            condP=obj.reduceToBool(obj.getEvidence(data,targetClasses,1:length(data),'single'));
            badIndices=sum(condP(:,:),1)<obj.minSamples;
            condP=condP./repmat(sum(condP,1)+eps,[2 1]);
            condP(:,badIndices)=repmat(margP,[1 sum(badIndices)]);
        end
    end
    methods(Access='protected')        
        function euCond=computeExpectedUtilityConditional(obj,booleanCP,decisionVec,valueMatrix)
            decisionVecOpp=3-decisionVec;
            euCond=booleanCP(decisionVec+ones(size(decisionVec,1),1)*(0:size(booleanCP,2)-1)*size(booleanCP,1)).*...
                obj.selectVal(valueMatrix,decisionVec,decisionVec)+...
                booleanCP(decisionVecOpp+ones(size(decisionVec,1),1)*(0:size(booleanCP,2)-1)*size(booleanCP,1)).*...
                obj.selectVal(valueMatrix,decisionVec,decisionVecOpp);
        end
        
        function dec=computeCostOptimalDecisions(obj,booleanCP,valueMatrix)
            tmpDecision=[1;2]*ones(1,size(booleanCP,2));
            tmpEU=obj.computeExpectedUtilityConditional(booleanCP,tmpDecision,valueMatrix);
            [~,dec]=max(tmpEU,[],1);
        end
    end
end