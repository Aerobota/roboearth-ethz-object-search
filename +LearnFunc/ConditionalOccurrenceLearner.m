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
%             margP=obj.evidenceGenerator.getEvidence(data,obj.classes,[]);
%             margP=margP./repmat(sum(margP,1),[size(margP,1) 1]);
%             booleanMargP=[margP(1,:);sum(margP(2:end,:),1)];
            [booleanMargP,~]=obj.computeESS(data,[]);
            for cs=obj.smallIndex
                dependencies.(obj.classes{cs}).parents=cell(1,0);
%                 EUBase=obj.computeExpectedUtilityBase(booleanMargP(:,cs));
                EULast=obj.computeExpectedUtilityConditional(booleanMargP(:,cs),1);
%                 EULast=EUBase;
                currentIndices=cs;
                while(length(currentIndices)-1<obj.maxParents)
                    [booleanCP,tmpMargP]=obj.computeESS(data,currentIndices);
%                     cp=obj.evidenceGenerator.getEvidence(data,obj.classes,currentIndices);
%                     tmpMargP=sum(cp,1)/(sum(cp(:))/size(cp,ndims(cp)));
%                     cp=cp./(repmat(sum(cp,1),[size(cp,1) ones(1,ndims(cp)-1)])+eps);
%                     tmpSize=size(cp);
%                     booleanCP=zeros([tmpSize(1)-1 tmpSize(2:end)]);
%                     booleanCP(1:size(booleanCP,1):numel(booleanCP))=cp(1:size(cp,1):numel(cp));
%                     booleanCP(2:size(booleanCP,1):numel(booleanCP))=sum(cp(2:end,:),1);
                    EUNew=obj.computeExpectedUtilityConditional(booleanCP,tmpMargP);
                    EUDiff=EUNew-EULast;
                    EUDiff(currentIndices)=0;
                    EUDiff(obj.smallIndex)=0;
                    EUDiff(EUDiff<0.001)=0;
                    [maxVal,maxI]=max(EUDiff);
                    if maxVal>0
                        currentIndices(end+1)=maxI;
                        EULast=EUNew(maxI);
                        dependencies.(obj.classes{cs}).parents{end+1}=obj.classes{maxI};
                        lastGoodBooleanCP=booleanCP;
                        lastGoodIndex=maxI;
                        disp([obj.classes{cs} ' given ' obj.classes{maxI} ' improvement: ' num2str(maxVal) ' total: ' num2str(EUNew(maxI))]);
                        warning('need complexity penalty')
                    else
                        break;
                    end
                end
                dependencies.(obj.classes{cs}).condProb=obj.cleanBooleanCP(lastGoodBooleanCP,lastGoodIndex);
            end
        end
%         function dependencies=learnStructure(obj,data)
%             tmpSum=sum(samples,3)+eps;
%             cp=samples./tmpSum(:,:,ones(size(samples,3),1),:);
%             margP=sum(samples(:,1,:,:),4);
%             margP=squeeze(margP./repmat(sum(margP,3),[1 1 size(margP,3)]));
%             booleanMargP=[margP(:,1) sum(margP(:,2:end),2)];
%             booleanMargP=permute(booleanMargP,[1 3 2]);
%             booleanCP=cp;
%             booleanCP(:,:,2,:)=sum(booleanCP(:,:,2:end,:),3);
%             booleanCP(:,:,3:end,:)=[];
%             EUBase=obj.computeExpectedUtilityBase(booleanMargP);
%             disp(EUBase)
%             EUCond=obj.computeExpectedUtilityConditional(booleanCP,margP);
%             EUGain=EUCond-EUBase(:,ones(1,size(EUCond,2)));
%             EUGain=EUGain-diag(diag(EUGain));
%             [i,j]=ind2sub([length(obj.classes) length(obj.classes)],find(EUGain>0.01));
%             for c=1:length(obj.classes)
%                 collection=i==c;
%                 disp([obj.classes{c} ' given ' obj.classes{j(collection)}])
%             end
%         end
%         
    end
    methods(Access='protected')
        function [boolCP,margP]=computeESS(obj,data,currentIndices)
            cp=obj.evidenceGenerator.getEvidence(data,obj.classes,currentIndices);
            margP=sum(cp,1)/(sum(cp(:))/size(cp,ndims(cp)));
            cp=cp./(repmat(sum(cp,1),[size(cp,1) ones(1,ndims(cp)-1)])+eps);
            tmpSize=size(cp);
            boolCP=zeros([tmpSize(1)-1 tmpSize(2:end)]);
            boolCP(1:size(boolCP,1):numel(boolCP))=cp(1:size(cp,1):numel(cp));
            boolCP(2:size(boolCP,1):numel(boolCP))=sum(cp(2:end,:),1);
        end
%         function eu=computeExpectedUtilityBase(obj,booleanMargP)
%             [~,maxI]=max(booleanMargP,[],1);
%             minI=3-maxI;
%             eu=booleanMargP(maxI).*obj.valueMatrix(maxI,maxI)+...
%                 booleanMargP(minI).*obj.valueMatrix(maxI,minI);
%         end
        
        function eu=computeExpectedUtilityConditional(obj,booleanCP,margP)
            eu=zeros(1,size(booleanCP,ndims(booleanCP)));
            tmpCP=booleanCP(1:size(booleanCP,1),:);
            tmpMargP=margP(1,:);
            
            tmpCoeff=size(tmpCP,2)/length(eu);
            [~,maxI]=max(tmpCP,[],1);
            minI=3-maxI;
            euCond=tmpCP(maxI+(0:size(tmpCP,2)-1)*size(tmpCP,1)).*obj.selectVal(obj.valueMatrix,maxI,maxI)+...
                tmpCP(minI+(0:size(tmpCP,2)-1)*size(tmpCP,1)).*obj.selectVal(obj.valueMatrix,maxI,minI);
            eu=sum(reshape(euCond.*tmpMargP,[tmpCoeff length(eu)]),1);
%             tmpEU=eu;
            
%             eu=zeros(1,size(booleanCP,ndims(booleanCP)));
%             tmpCoeff=length(eu)/size(tmpCP,2);
%             for i=1:size(tmpCP,2)
%                 [~,maxI]=max(tmpCP(:,i),[],1);
%                 minI=3-maxI;
%                 euCond=tmpCP(maxI,i).*obj.valueMatrix(maxI,maxI)+...
%                     tmpCP(minI,i).*obj.valueMatrix(maxI,minI);
%                 tmpIndex=floor((i-1)*tmpCoeff)+1;
%                 eu(tmpIndex)=eu(tmpIndex)+euCond.*tmpMargP(i);
%             end
%             disp([eu;tmpEU])
        end
    end
    methods(Static)
%         function out=selectCol(in,index)
%             out=in((index-1)*size(in,1)*size(in,2)+repmat((1:size(index,1))',[1 size(index,2)])+...
%                 (repmat(1:size(index,2),[size(index,1) 1])-1)*size(in,1));
%         end
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