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
            allCBins=DataHandlers.StateBinsBuffer.getCBins(data,obj);
            
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
    end
end