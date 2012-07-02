classdef VerticalDistanceEvidenceGenerator<LearnFunc.EvidenceGenerator
    methods(Static)
        function evidence=getAbsoluteEvidence(image)
            pos=LearnFunc.VerticalDistanceEvidenceGenerator.getPositionEvidence(image);
            evidence(:,:,1)=pos(ones(length(pos),1),:);
        end
        function evidence=getRelativeEvidence(image)
            pos=LearnFunc.VerticalDistanceEvidenceGenerator.getPositionEvidence(image);
            evidence(:,:,1)=pos(ones(length(image.annotation.object),1),:)...
                -pos(ones(length(image.annotation.object),1),:)';
        end
    end
    methods(Static,Access='protected')
        function pos=getPositionEvidence(image)
            for o=length(image.annotation.object):-1:1
                pos(1,o)=mean(image.getObject(1,o).polygon.y)/image.annotation.imagesize.nrows;
            end
        end
    end
end