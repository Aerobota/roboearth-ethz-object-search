classdef ConditionalOccurrenceLearner<LearnFunc.OccurrenceLearner
    properties(SetAccess='protected')
        valueMatrix % valueMatrix=[trueNegativ falseNegativ;falsePositiv truePositiv]
        maxParents
    end
    
    properties(Constant) 
        nrSplits=10
        defaultMaxParents=10
    end
    
    methods
        function obj=ConditionalOccurrenceLearner(evidenceGenerator,valueMatrix,maxParents)
            obj=obj@LearnFunc.OccurrenceLearner(evidenceGenerator);
            
            obj.valueMatrix=valueMatrix;
            if nargin>=3
                obj.maxParents=maxParents;
            else
                obj.maxParents=obj.defaultMaxParents;
            end
        end
        
        function learn(obj,data)
            % get classes and indices of small classes
            classes=data.getClassNames();
            smallIndex=data.className2Index(data.getSmallClassNames());
            
            % generate dataset splits
            for i=obj.nrSplits:-1:1
                tmpIndices=randperm(length(data));
                setIndices{i,2}=tmpIndices(ceil(length(tmpIndices)/2)+1:end);
                setIndices{i,1}=tmpIndices(1:ceil(length(tmpIndices)/2));
            end
            
            % calculate the base expected utility for all classes
            EUBase=obj.computeExpectedUtilitySplitDataset(data,[],setIndices);
            
            % for every small class greedy search for best parents
            for cs=smallIndex
                EULast=EUBase(cs);
                currentIndices=cs;
                goodIndices=cs;
                while(length(currentIndices)-1<obj.maxParents)
                    EUNew=obj.computeExpectedUtilitySplitDataset(data,currentIndices,setIndices);
                    EUDiff=EUNew-EULast;
                    EUDiff(currentIndices)=0;
                    EUDiff(smallIndex)=0;
                    EUDiff(EUDiff<0.001)=0;
                    [maxVal,maxI]=max(EUDiff);
                    if maxVal>0
                        currentIndices(end+1)=maxI;
                        EULast=EUNew(maxI);
                        goodIndices=currentIndices;
                        disp([classes{cs} ' given ' classes{maxI} ' improvement: ' num2str(maxVal) ' total: ' num2str(EULast)]);
                    else
                        break;
                    end
                end
                if ~isempty(goodIndices)
                    obj.model.(classes{cs}).parents=classes(goodIndices(2:end));
                    
                    obj.model.(classes{cs}).expectedUtility=EULast;
                    
                    [booleanCPComplete,~]=obj.computeESS(data,goodIndices,1:length(data),'single');
                    [booleanMargP,~]=obj.computeESS(data,cs,1:length(data),'single');
                    obj.model.(classes{cs}).margP=booleanMargP;
                    obj.model.(classes{cs}).condProb=obj.cleanBooleanCP(booleanCPComplete,booleanMargP);
                                        
                    tmpSize=size(obj.model.(classes{cs}).condProb);
                    obj.model.(classes{cs}).optimalDecision=zeros([1 tmpSize(2:end)]);
                    obj.model.(classes{cs}).optimalDecision(:)=...
                        obj.computeCostOptimalDecisions(obj.model.(classes{cs}).condProb(:,:));
                end
            end
        end
        
        function result=calculateStatistics(obj,testData,occEval)
            myNames=obj.getLearnedClasses();
            
            for i=length(myNames):-1:1
                searchIndices=testData.className2Index([myNames(i) obj.model.(myNames{i}).parents]);
                
                evidence=obj.evidenceGenerator.getEvidence(testData,searchIndices,1:length(testData),'single');
                tmpSize=size(evidence);
                boolEvidence=zeros([2 tmpSize(2:end)]);
                boolEvidence(1,:)=evidence(1,:);
                boolEvidence(2,:)=sum(evidence(2:end,:),1);
                
                decisions=occEval.decisionImpl(obj.model.(myNames{i}));
                
                neg=repmat(boolEvidence(1,:),[size(decisions,1) 1]);
                pos=repmat(boolEvidence(2,:),[size(decisions,1) 1]);
                
                result.tp(:,i)=sum(pos.*(decisions(:,:)==2),2);
                result.fp(:,i)=sum(neg.*(decisions(:,:)==2),2);
                result.pos(1,i)=sum(boolEvidence(2,:),2);
                result.neg(1,i)=sum(boolEvidence(1,:),2);
                
                result.expectedUtility(1,i)=obj.model.(myNames{i}).expectedUtility;
            end
        end
    end
    methods(Access='protected')
        function EUNew=computeExpectedUtilitySplitDataset(obj,data,currentIndices,setIndices)
            EUNew=[];
            for i=1:size(setIndices,1)
                [booleanCP{2},tmpMargP{2}]=obj.computeESS(data,currentIndices,setIndices{i,2},'all');
                [booleanCP{1},tmpMargP{1}]=obj.computeESS(data,currentIndices,setIndices{i,1},'all');
                EUNew=[EUNew;obj.computeExpectedUtility(booleanCP{1},tmpMargP{1},booleanCP{2});...
                    obj.computeExpectedUtility(booleanCP{2},tmpMargP{2},booleanCP{1})];
            end
            EUNew=median(EUNew,1);
        end
        function [boolCP,margP]=computeESS(obj,data,currentIndices,subsetIndices,mode)
            cp=obj.evidenceGenerator.getEvidence(data,currentIndices,subsetIndices,mode);
            margP=sum(cp,1)/(sum(cp(:))/size(cp,ndims(cp)));
            cp=cp./(repmat(sum(cp,1),[size(cp,1) ones(1,ndims(cp)-1)])+eps);
            tmpSize=size(cp);
            boolCP=zeros([2 tmpSize(2:end)]);
            boolCP(1,:)=cp(1,:);
            boolCP(2,:)=sum(cp(2:end,:),1);
        end
        
        function eu=computeExpectedUtility(obj,booleanCP,margP,booleanDecisionCP)
            eu=zeros(1,size(booleanCP,ndims(booleanCP)));
            tmpCP=booleanCP(:,:);
            tmpDecisionCP=booleanDecisionCP(:,:);
            tmpMargP=margP(1,:);
            tmpCoeff=size(tmpCP,2)/length(eu);
            optDec=obj.computeCostOptimalDecisions(tmpDecisionCP);
            euCond=obj.computeExpectedUtilityConditional(tmpCP,optDec);
            eu=sum(reshape(euCond.*tmpMargP,[tmpCoeff length(eu)]),1);
        end
        
        function euCond=computeExpectedUtilityConditional(obj,booleanCP,decisionVec)
            decisionVecOpp=3-decisionVec;
            euCond=booleanCP(decisionVec+ones(size(decisionVec,1),1)*(0:size(booleanCP,2)-1)*size(booleanCP,1)).*...
                obj.selectVal(obj.valueMatrix,decisionVec,decisionVec)+...
                booleanCP(decisionVecOpp+ones(size(decisionVec,1),1)*(0:size(booleanCP,2)-1)*size(booleanCP,1)).*...
                obj.selectVal(obj.valueMatrix,decisionVec,decisionVecOpp);
        end
        
        function dec=computeCostOptimalDecisions(obj,booleanCP)
            tmpDecision=(1:2)'*ones(1,size(booleanCP,2));
            tmpEU=obj.computeExpectedUtilityConditional(booleanCP,tmpDecision);
            [~,dec]=max(tmpEU,[],1);
        end
    end
    methods(Static)
        function out=selectVal(in,i,j)
            out=in((j-1)*size(in,1)+i);
        end
        
        function out=cleanBooleanCP(boolCP,boolMargP)
            out=boolCP;
            zeroIndexes=sum(out(:,:),1)==0;
            out(:,zeroIndexes)=boolMargP(:,ones(1,sum(zeroIndexes)));
        end
    end
end