classdef CylindricEvidenceGenerator<LearnFunc.EvidenceGenerator
    methods(Static)
        function evidence=getEvidence(image)
            pos=[image.annotation.object.pos];

            for d=3:-1:1
                dist(:,:,d)=bsxfun(@minus,pos(d,:)',pos(d,:));
            end
            
            evidence(:,:,2)=dist(:,:,1);
            evidence(:,:,1)=sqrt(dist(:,:,2).^2+dist(:,:,3).^2);
        end
    end
end