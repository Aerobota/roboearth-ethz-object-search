classdef ConditionalOccurrenceLearner<LearnFunc.StructureLearner
    properties(SetAccess='protected')
        evidenceGenerator
        smallClasses
        valueMatrix % valueMatrix=[trueNegativ falseNegativ;falsePositiv truePositiv]
    end
    
    properties(Constant)
%         % valueMatrix=[trueNegativ falseNegativ;falsePositiv truePositiv]
%         valueMatrix=[0 -1;-0.5 1]
% %         valueMatrix=[1 -1;-1 1] 
        nrSplits=10
        maxParents=10
    end
    
    methods
%         function obj=ConditionalOccurrenceLearner(classes,evidenceGenerator,largeClasses,maxParents,valueMatrix)
%             obj=obj@LearnFunc.StructureLearner(classes);
%             obj.evidenceGenerator=evidenceGenerator;
%             
%             [~,obj.largeIndex]=ismember(largeClasses,obj.classes);
%             obj.smallIndex=1:length(obj.classes);
%             obj.smallIndex(obj.largeIndex)=[];
%             
%             obj.maxParents=maxParents;
%             obj.valueMatrix=valueMatrix;
%         end
        function obj=ConditionalOccurrenceLearner(evidenceGenerator,smallClasses,valueMatrix)
            obj.evidenceGenerator=evidenceGenerator;
            
            obj.smallClasses=smallClasses;
            
            obj.valueMatrix=valueMatrix;
        end
        
        function dependencies=learnStructure(obj,data)
            % get classes and indices of small indices
            classes=data.getClassNames();
            smallIndex=data.className2Index(obj.smallClasses);
            
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
                        disp([classes{cs} ' given ' classes{maxI} ' improvement: ' num2str(maxVal) ' total: ' num2str(EUNew(maxI))]);
                    else
                        break;
                    end
                end
                if ~isempty(goodIndices)
                    dependencies.(classes{cs}).parents=classes(goodIndices(2:end));
                    [booleanCPComplete,~]=obj.computeESS(data,goodIndices(1:end-1),1:length(data));
                    [booleanMargP,~]=obj.computeESS(data,[],1:length(data));
                    dependencies.(classes{cs}).condProb=obj.cleanBooleanCP(booleanCPComplete,booleanMargP,goodIndices(end));
                    tmpSize=size(dependencies.(classes{cs}).condProb);
                    dependencies.(classes{cs}).optimalDecision=zeros([1 tmpSize(2:end)]);
                    dependencies.(classes{cs}).optimalDecision(:)=...
                        obj.computeCostOptimalDecisions(dependencies.(classes{cs}).condProb(:,:));
                end
            end
        end
    end
    methods(Access='protected')
        function EUNew=computeExpectedUtilitySplitDataset(obj,data,currentIndices,setIndices)
            EUNew=[];
            for i=1:size(setIndices,1)
                [booleanCP{2},tmpMargP{2}]=obj.computeESS(data,currentIndices,setIndices{i,2});
                [booleanCP{1},tmpMargP{1}]=obj.computeESS(data,currentIndices,setIndices{i,1});
                EUNew=[EUNew;obj.computeExpectedUtility(booleanCP{1},tmpMargP{1},booleanCP{2});...
                    obj.computeExpectedUtility(booleanCP{2},tmpMargP{2},booleanCP{1})];
            end
            EUNew=median(EUNew,1);
        end
        function [boolCP,margP]=computeESS(obj,data,currentIndices,subsetIndices)
            cp=obj.evidenceGenerator.getEvidence(data,currentIndices,subsetIndices);
            margP=sum(cp,1)/(sum(cp(:))/size(cp,ndims(cp)));
            cp=cp./(repmat(sum(cp,1),[size(cp,1) ones(1,ndims(cp)-1)])+eps);
            tmpSize=size(cp);
%             boolCP=zeros([tmpSize(1)-1 tmpSize(2:end)]);
%             boolCP(1:size(boolCP,1):numel(boolCP))=cp(1:size(cp,1):numel(cp));
%             boolCP(2:size(boolCP,1):numel(boolCP))=sum(cp(2:end,:),1);
            boolCP=zeros([tmpSize(1)-1 tmpSize(2:end)]);
            boolCP(1,:)=cp(1,:);
            boolCP(2,:)=sum(cp(2:end,:),1);
        end
        
        function eu=computeExpectedUtility(obj,booleanCP,margP,booleanDecisionCP)
            eu=zeros(1,size(booleanCP,ndims(booleanCP)));
            tmpCP=booleanCP(:,:);
            tmpDecisionCP=booleanDecisionCP(:,:);
            tmpMargP=margP(1,:);
            
%             if any(tmpMargP(1,sum(tmpCP,1)==0)>0)
%                 disp(tmpMargP(1,sum(tmpCP,1)==0))
%                 error('stop')
%             end
            
            tmpCoeff=size(tmpCP,2)/length(eu);
%             [~,maxI]=max(tmpDecisionCP,[],1);
            optDec=obj.computeCostOptimalDecisions(tmpDecisionCP);
%             minI=3-maxI;
%             euCond=tmpCP(maxI+(0:size(tmpCP,2)-1)*size(tmpCP,1)).*obj.selectVal(obj.valueMatrix,maxI,maxI)+...
%                 tmpCP(minI+(0:size(tmpCP,2)-1)*size(tmpCP,1)).*obj.selectVal(obj.valueMatrix,maxI,minI);
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
        
        function out=cleanBooleanCP(boolCP,boolMargP,index)
            s=size(boolCP);
            if length(s)<=2
                out=zeros([s(1:end-1) 1]);
            else
                out=zeros(s(1:end-1));
            end
            out(:)=boolCP((index-1)*prod(s(1:end-1))+1:index*prod(s(1:end-1)));
            zeroIndexes=sum(out(:,:),1)==0;
            out(:,zeroIndexes)=boolMargP(:,index*ones(1,sum(zeroIndexes)));
        end
    end
end