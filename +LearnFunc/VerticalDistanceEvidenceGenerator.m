classdef VerticalDistanceEvidenceGenerator<LearnFunc.EvidenceGenerator
    methods(Static)
        function evidence=getEvidence(image)
            nObj=length(image.annotation.object);
            pos=zeros(2,nObj);
            for o=1:nObj
                pos(:,o)=[mean(image.annotation.object(o).polygon.x/image.annotation.imagesize.ncols);...
                    mean(image.annotation.object(o).polygon.y/image.annotation.imagesize.nrows)];
            end

            evidence(:,:,1)=pos(2*ones(nObj,1),:)-pos(2*ones(nObj,1),:)';
        end
    end
end