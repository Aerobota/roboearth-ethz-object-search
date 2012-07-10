classdef ConditionalOccurenceLearner<LearnFunc.ParameterLearner
    properties(Constant)
        valueMatrix=[1 -1;-1 1] % value=[trueNegativ falseNegativ;falsePositiv truePositiv]
    end
    
    methods
        function obj=ConditionalOccurenceLearner(classes,evidenceGenerator)
            obj=obj@LearnFunc.ParameterLearner(classes,evidenceGenerator);  
        end
        
        function CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass)
            error('ParameterLearner:notImplemented','This function is not implemented.')
        end
    end
    methods(Access='protected')
        function evaluateOrderedSamples(obj,samples)
            tmpSum=sum(samples,3)+eps;
            cp=samples./tmpSum(:,:,ones(size(samples,3),1),:);
            margP=sum(samples(:,1,:,:),4);
            margP=squeeze(margP./repmat(sum(margP,3),[1 1 size(margP,3)]));
            booleanMargP=[margP(:,1) sum(margP(:,2:end),2)];
            booleanMargP=permute(booleanMargP,[1 3 2]);
            booleanCP=cp;
            booleanCP(:,:,2,:)=sum(booleanCP(:,:,2:end,:),3);
            booleanCP(:,:,3:end,:)=[];
%             EUBase=max(booleanMargP,[],3)-min(booleanMargP,[],3);
            EUBase=obj.computeExpectedUtilityBase(booleanMargP);
            disp(EUBase)
            EUCond=obj.computeExpectedUtilityConditional(booleanMargP,booleanCP,margP);
            EUGain=EUCond-EUBase(:,ones(1,size(EUCond,2)));
%             disp(EUCond)
%             disp(EUGain)
        end
        
        function eu=computeExpectedUtilityBase(obj,booleanMargP)
            [~,maxI]=max(booleanMargP,[],3);
            minI=3-maxI;
            eu=obj.selectCol(booleanMargP,maxI).*obj.selectVal(obj.valueMatrix,maxI,maxI)+...
                obj.selectCol(booleanMargP,minI).*obj.selectVal(obj.valueMatrix,maxI,minI);
        end
        
        function eu=computeExpectedUtilityConditional(obj,booleanMargP,booleanCP,margP)
            eu=zeros(size(booleanCP,1),size(booleanCP,2));
            [valMarg,maxIMarg]=max(booleanMargP,[],3);
            for i=1:size(booleanCP,4)
                [valCond,maxICond]=max(booleanCP(:,:,:,i),[],3);
                disp(maxIChooser)
                minI=3-maxI;
                euCond=obj.selectCol(booleanCP,maxI).*obj.selectVal(obj.valueMatrix,maxI,maxI)+...
                    obj.selectCol(booleanCP,minI).*obj.selectVal(obj.valueMatrix,maxI,minI);
%                 size(euCond)
%                 size(margP(:,i))
%                 size(repmat(margP(:,i)',[size(booleanCP,1) 1]))
                eu=eu+euCond.*repmat(margP(:,i)',[size(booleanCP,1) 1]);
% eu=eu+euCond;
            end
        end
    end
    methods(Static)
        function out=selectCol(in,index)
            out=in((index-1)*size(in,1)*size(in,2)+repmat((1:size(index,1))',[1 size(index,2)])+...
                (repmat(1:size(index,2),[size(index,1) 1])-1)*size(in,1));
        end
        function out=selectVal(in,i,j)
            out=in((j-1)*size(in,1)+i);
        end
    end
end