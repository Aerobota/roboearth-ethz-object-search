classdef VerticalDistanceEvidenceGenerator<LearnFunc.LocationEvidenceGenerator
    methods(Static,Access='protected')
        function evidence=getAbsoluteEvidence(pos)
            evidence(:,:,1)=pos(ones(length(pos),1),:);
        end
        function evidence=getRelativeEvidence(sourcePos,targetPos)
            evidence(:,:,1)=sourcePos(ones(size(sourcePos,2),1),:)-targetPos(ones(size(sourcePos,2),1),:)';
        end
        function pos=getPositionEvidence(images,index)
            tmpObjects=images.getObject(index);
            for o=length(tmpObjects):-1:1
                pos(1,o)=mean(tmpObjects(o).polygon.y)/images.getImagesize(index).nrows;
            end
        end
    end
end