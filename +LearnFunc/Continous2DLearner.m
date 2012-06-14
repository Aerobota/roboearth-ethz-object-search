classdef Continous2DLearner<LearnFunc.LocationLearner
    properties(Constant)
        minSamples=20;
    end
    properties(SetAccess='protected')
        data;
    end
    
    methods
        function obj=Continous2DLearner(classes,heights)
            obj=obj@LearnFunc.LocationLearner(classes);
            for c=1:length(obj.classes)
                obj.data.(obj.classes{c}).height=heights(c);
                for o=1:length(obj.classes)
                    obj.data.(obj.classes{c}).(obj.classes{o}).mean=[];
                    obj.data.(obj.classes{c}).(obj.classes{o}).cov=[];
                end
            end
        end
        
        function CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass)
            assert(~isempty(obj.data.(fromClass).(toClass).mean),...
                'Continous2DLearner:getConnectionNodeCPD:missingConnectionData',...
                'The requested classes have too few cooccurences to generate a CPD');
            CPD=gaussian_CPD(network,nodeNumber,'mean',obj.data.(fromClass).(toClass).mean,...
                'cov',obj.data.(fromClass).(toClass).cov);
        end
    end
    methods(Static)
        function evidence=getEvidence(image)
            nObj=length(image.annotation.object);
            pos=zeros(2,nObj);
            for o=1:nObj
                pos(:,o)=[mean(image.annotation.object(o).polygon.x/image.annotation.imagesize.ncols);...
                    mean(image.annotation.object(o).polygon.y/image.annotation.imagesize.nrows)];
            end

            evidence(:,:,2)=pos(2*ones(nObj,1),:)-pos(2*ones(nObj,1),:)';
            evidence(:,:,1)=abs(pos(ones(nObj,1),:)-pos(ones(nObj,1),:)');
        end
    end
    methods(Access='protected')
        function evaluateOrderedSamples(obj,samples)
            for i=1:length(obj.classes)
                for j=i:length(obj.classes)
                    if size(samples{i,j},1)>=obj.minSamples;
                        tmpMean=mean(samples{i,j});
                        tmpCov=cov(samples{i,j});
                        obj.data.(obj.classes{j}).(obj.classes{i}).mean=[tmpMean(1);-tmpMean(2)];
                        obj.data.(obj.classes{j}).(obj.classes{i}).cov=tmpCov;
                        obj.data.(obj.classes{i}).(obj.classes{j}).mean=tmpMean';
                        obj.data.(obj.classes{i}).(obj.classes{j}).cov=tmpCov;
                    end
                end
            end
        end
    end
end