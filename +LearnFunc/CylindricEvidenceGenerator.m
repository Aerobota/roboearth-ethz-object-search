classdef CylindricEvidenceGenerator<LearnFunc.EvidenceGenerator
    methods(Static)
        function evidence=getRelativeEvidence(image)
            pos=LearnFunc.CylindricEvidenceGenerator.getPositionEvidence(image);

            for d=3:-1:1
                dist(:,:,d)=bsxfun(@minus,pos(d,:)',pos(d,:));
            end
            
            evidence(:,:,2)=dist(:,:,1);
            evidence(:,:,1)=sqrt(dist(:,:,2).^2+dist(:,:,3).^2);
        end
        function evidence=getAbsoluteEvidence(image)
            pos=LearnFunc.CylindricEvidenceGenerator.getPositionEvidence(image);
            relEvi=LearnFunc.CylindricEvidenceGenerator.getRelativeEvidence(image);
            evidence=repmat(pos,[1 1 size(pos,2)]);
            evidence=permute(evidence,[2,3,1]);
            evidence(:,:,1)=evidence(:,:,1)-relEvi(:,:,2);
            evidence(:,:,2)=evidence(:,:,2)+relEvi(:,:,1);
            evidence=evidence(:,:,1:2);
        end
    end
    methods(Static,Access='protected')
        function pos=getPositionEvidence(image)
            pos=[image.annotation.object.pos];
        end
    end
end