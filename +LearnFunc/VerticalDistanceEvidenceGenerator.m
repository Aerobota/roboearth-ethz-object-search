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
            for o=length(image.getObject(1)):-1:1
                pos(1,o)=mean(image.getObject(1,o).polygon.y)/image.getImagesize(1).nrows;
            end
        end
    end
end