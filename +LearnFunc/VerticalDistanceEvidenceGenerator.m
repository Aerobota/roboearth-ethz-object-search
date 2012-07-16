classdef VerticalDistanceEvidenceGenerator<LearnFunc.LocationEvidenceGenerator
    methods(Static,Access='protected')
        function evidence=getAbsoluteEvidence(pos)
            evidence(:,:,1)=pos(ones(length(pos),1),:);
        end
        function evidence=getRelativeEvidence(sourcePos,targetPos)
%             pos=LearnFunc.VerticalDistanceEvidenceGenerator.getPositionEvidence(images,index);
%             nObj=length(images.getObject(index));
            nObj=size(sourcePos,2);
            evidence(:,:,1)=sourcePos(ones(nObj,1),:)-targetPos(ones(nObj,1),:)';
        end
    end
    methods(Static,Access='protected')
        function pos=getPositionEvidence(images,index)
            tmpObjects=images.getObject(index);
            for o=length(tmpObjects):-1:1
                pos(1,o)=mean(tmpObjects(o).polygon.y)/images.getImagesize(index).nrows;
            end
        end
    end
end