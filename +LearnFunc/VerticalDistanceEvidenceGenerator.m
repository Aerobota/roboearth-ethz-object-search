classdef VerticalDistanceEvidenceGenerator<LearnFunc.EvidenceGenerator
    methods(Static)
        function pos=getAbsoluteEvidence(image)
            p=[image.annotation.object.polygon];
            pos=mean(vertcat(p.y)'/image.annotation.imagesize.nrows);
        end
        function evidence=getRelativeEvidence(image)
            pos=LearnFunc.VerticalDistanceEvidenceGenerator.getAbsoluteEvidence(image);
            evidence(:,:,1)=pos(ones(length(image.annotation.object),1),:)...
                -pos(ones(length(image.annotation.object),1),:)';
        end
    end
end