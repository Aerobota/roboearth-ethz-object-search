classdef ConditionalOccurrenceLearner<LearnFunc.StructureLearner
    properties(SetAccess='protected')
        evidenceGenerator
        largeIndex
        smallIndex
        maxParents
    end
    
    properties(Constant)
        valueMatrix=[1 -1;-1 1] % value=[trueNegativ falseNegativ;falsePositiv truePositiv]
    end
    
    methods
        function obj=ConditionalOccurrenceLearner(classes,evidenceGenerator,largeClasses,maxParents)
            obj=obj@LearnFunc.StructureLearner(classes);
            obj.evidenceGenerator=evidenceGenerator;
            
            [~,obj.largeIndex]=ismember(largeClasses,obj.classes);
            obj.smallIndex=1:length(obj.classes);
            obj.smallIndex(obj.largeIndex)=[];
            
            obj.maxParents=maxParents;
        end
        
        function dependencies=learnStructure(obj,data)
            tmpIndices=randperm(length(data));
            setIndices{2}=tmpIndices(ceil(length(tmpIndices)/2)+1:end);
            setIndices{1}=tmpIndices(1:ceil(length(tmpIndices)/2));
            [booleanMargP{2},~]=obj.computeESS(data,[],setIndices{2});
            [booleanMargP{1},~]=obj.computeESS(data,[],setIndices{1});
            for cs=obj.smallIndex
%                 dependencies.(obj.classes{cs}).parents=cell(1,0);
                EULast=mean([obj.computeExpectedUtilityConditional(booleanMargP{1}(:,cs),1,booleanMargP{2}(:,cs))...
                    obj.computeExpectedUtilityConditional(booleanMargP{2}(:,cs),1,booleanMargP{1}(:,cs))]);
                currentIndices=cs;
                while(length(currentIndices)-1<obj.maxParents)
                    [booleanCP{2},tmpMargP{2}]=obj.computeESS(data,currentIndices,setIndices{2});
                    [booleanCP{1},tmpMargP{1}]=obj.computeESS(data,currentIndices,setIndices{1});
                    EUNew=mean([obj.computeExpectedUtilityConditional(booleanCP{1},tmpMargP{1},booleanCP{2});...
                        obj.computeExpectedUtilityConditional(booleanCP{2},tmpMargP{2},booleanCP{1})],1);
%                     EUNew=median([obj.computeExpectedUtilityConditional(booleanCP{1},tmpMargP{1},booleanCP{2});...
%                         obj.computeExpectedUtilityConditional(booleanCP{2},tmpMargP{2},booleanCP{1})],1);
%                     EUNew=min([obj.computeExpectedUtilityConditional(booleanCP{1},tmpMargP{1},booleanCP{2});...
%                         obj.computeExpectedUtilityConditional(booleanCP{2},tmpMargP{2},booleanCP{1})],[],1);
                    EUDiff=EUNew-EULast;
                    EUDiff(currentIndices)=0;
                    EUDiff(obj.smallIndex)=0;
                    EUDiff(EUDiff<0.001)=0;
                    [maxVal,maxI]=max(EUDiff);
                    if maxVal>0
                        currentIndices(end+1)=maxI;
                        EULast=EUNew(maxI);
%                         dependencies.(obj.classes{cs}).parents{end+1}=obj.classes{maxI};
%                         lastGoodBooleanCP=booleanCP;
                        goodIndices=[currentIndices maxI];
                        disp([obj.classes{cs} ' given ' obj.classes{maxI} ' improvement: ' num2str(maxVal) ' total: ' num2str(EUNew(maxI))]);
%                         warning('need complexity penalty')
                    else
                        break;
                    end
                end
                dependencies.(obj.classes{cs}).parents=obj.classes(goodIndices);
                [booleanCPComplete,~]=obj.computeESS(data,goodIndices(1:end-1),1:length(data));
                dependencies.(obj.classes{cs}).condProb=obj.cleanBooleanCP(booleanCPComplete,goodIndices(end));
            end
        end
    end
    methods(Access='protected')
        function [boolCP,margP]=computeESS(obj,data,currentIndices,subsetIndices)
            cp=obj.evidenceGenerator.getEvidence(data,obj.classes,currentIndices,subsetIndices);
            margP=sum(cp,1)/(sum(cp(:))/size(cp,ndims(cp)));
            cp=cp./(repmat(sum(cp,1),[size(cp,1) ones(1,ndims(cp)-1)])+eps);
            tmpSize=size(cp);
            boolCP=zeros([tmpSize(1)-1 tmpSize(2:end)]);
            boolCP(1:size(boolCP,1):numel(boolCP))=cp(1:size(cp,1):numel(cp));
            boolCP(2:size(boolCP,1):numel(boolCP))=sum(cp(2:end,:),1);
        end
        
        function eu=computeExpectedUtilityConditional(obj,booleanCP,margP,booleanDecisionCP)
            eu=zeros(1,size(booleanCP,ndims(booleanCP)));
            tmpCP=booleanCP(1:size(booleanCP,1),:);
            tmpDecisionCP=booleanDecisionCP(1:size(booleanCP,1),:);
            tmpMargP=margP(1,:);
            
            tmpCoeff=size(tmpCP,2)/length(eu);
            [~,maxI]=max(tmpDecisionCP,[],1);
            minI=3-maxI;
            euCond=tmpCP(maxI+(0:size(tmpCP,2)-1)*size(tmpCP,1)).*obj.selectVal(obj.valueMatrix,maxI,maxI)+...
                tmpCP(minI+(0:size(tmpCP,2)-1)*size(tmpCP,1)).*obj.selectVal(obj.valueMatrix,maxI,minI);
            eu=sum(reshape(euCond.*tmpMargP,[tmpCoeff length(eu)]),1);
        end
    end
    methods(Static)
        function out=selectVal(in,i,j)
            out=in((j-1)*size(in,1)+i);
        end
        
        function out=cleanBooleanCP(in,index)
            s=size(in);
            out=zeros(s(1:end-1));
            out(:)=in((index-1)*prod(s(1:end-1))+1:index*prod(s(1:end-1)));
        end
    end
end