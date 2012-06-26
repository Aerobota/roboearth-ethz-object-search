classdef VerticalDistanceEvidenceGenerator<LearnFunc.EvidenceGenerator
    methods(Static)
        function pos=getAbsoluteEvidence(image)
            p=[image.annotation.object.polygon];
            pos=mean([p.y]/image.annotation.imagesize.nrows);
        end
        function evidence=getRelativeEvidence(image)
            pos=LearnFunc.VerticalDistanceEvidenceGenerator.getAbsoluteEvidence(image);

            evidence(:,:,1)=pos(2*ones(length(image.annotation.object),1),:)...
                -pos(2*ones(length(image.annotation.object),1),:)';
        end
    end
end