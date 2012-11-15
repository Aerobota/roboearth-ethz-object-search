classdef ConditionalOccurrenceEvidenceGenerator<LearnFunc.OccurrenceEvidenceGenerator
    %CONDITIONALOCCURRENCEEVIDENCEGENERATOR Computes the conditional probabilities
    %   Computes the probability of a sought class occurring given the
    %   states of a set of observed classes.
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
            
            % We simply count how many times a specific combination of
            % states occur. All the following code is matlab hackery to do
            % so efficiently
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
                
                % Get the evidence for the sought class and its parents
                evidence=obj.getEvidence(testData,searchIndices,1:length(testData),'single');
                tmpSize=size(evidence);
                % Reduce sought state to boolean absent/present
                boolEvidence=zeros([2 tmpSize(2:end)]);
                boolEvidence(1,:)=evidence(1,:);
                boolEvidence(2,:)=sum(evidence(2:end,:),1);
                
                % Make the predictions
                decisions=occEval.decisionImpl(occLearner.model.(myNames{i}));
                
                neg=repmat(boolEvidence(1,:),[size(decisions,1) 1]);
                pos=repmat(boolEvidence(2,:),[size(decisions,1) 1]);
                
                % Compute error statistics
                result.tp(:,i)=sum(pos.*(decisions(:,:)==2),2);
                result.fp(:,i)=sum(neg.*(decisions(:,:)==2),2);
                result.pos(1,i)=sum(boolEvidence(2,:),2);
                result.neg(1,i)=sum(boolEvidence(1,:),2);
                
                result.expectedUtility(1,i)=occLearner.model.(myNames{i}).expectedUtility;
            end
        end
        
        function eu=calculateExpectedUtility(obj,data,targetClasses,decisionSubset,testSubset,valueMatrix)
            % Get the probabilities for the decision set
            copDec=obj.reduceToBool(obj.getEvidence(data,targetClasses,decisionSubset,'all'));
            % Compute the cost optimal decision
            optDec=obj.computeCostOptimalDecisions(copDec(:,:),valueMatrix);
            % Get the probabilities for the test set
            copTest=obj.reduceToBool(obj.getEvidence(data,targetClasses,testSubset,'all'));
            % Compute the expected utility for all expected outcomes
            euCond=obj.computeExpectedUtilityConditional(copTest(:,:),optDec,valueMatrix);
            % Reduce to one eu per class by adding outcomes.
            eu=sum(reshape(euCond/(sum(copTest(:))/size(copTest,ndims(copTest))),...
                [numel(euCond)/size(copTest,ndims(copTest)) size(copTest,ndims(copTest))]),1);
        end
        
        function [margP,condP]=calculateModelStatistics(obj,data,targetClasses,subset)
            % Compute marginal and conditional probabilities
            margP=obj.reduceToBool(obj.getMarginalProbabilities(data,targetClasses(1),subset));
            condP=obj.reduceToBool(obj.getEvidence(data,targetClasses,subset,'single'));
            % Replace all unobserved state combinations with the marginal
            % probability
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
            % Compute eu for all possible decisions
            tmpDecision=[1;2]*ones(1,size(booleanCP,2));
            tmpEU=obj.computeExpectedUtilityConditional(booleanCP,tmpDecision,valueMatrix);
            % Select the optimal decisions
            [~,dec]=max(tmpEU,[],1);
        end
    end
end