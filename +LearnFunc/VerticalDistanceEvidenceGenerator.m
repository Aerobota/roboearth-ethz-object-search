classdef VerticalDistanceEvidenceGenerator<LearnFunc.LocationEvidenceGenerator
    methods(Static,Access='protected')
        function evidence=getAbsoluteEvidence(image)
            pos=LearnFunc.VerticalDistanceEvidenceGenerator.getPositionEvidence(image);
            evidence(:,:,1)=pos(ones(length(pos),1),:);
        end
        function evidence=getRelativeEvidence(image)
            pos=LearnFunc.VerticalDistanceEvidenceGenerator.getPositionEvidence(image);
            nObj=length(image.getObject(1));
            evidence(:,:,1)=pos(ones(nObj,1),:)-pos(ones(nObj,1),:)';
        end
    end
    methods(Static,Access='protected')
        function pos=getPositionEvidence(image)
            tmpObjects=image.getObject(1);
            for o=length(tmpObjects):-1:1
                pos(1,o)=mean(tmpObjects(o).polygon.y)/image.getImagesize(1).nrows;
            end
        end
    end
end