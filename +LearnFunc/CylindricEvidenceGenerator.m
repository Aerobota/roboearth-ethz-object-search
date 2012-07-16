classdef CylindricEvidenceGenerator<LearnFunc.LocationEvidenceGenerator
    methods(Static,Access='protected')
        function evidence=getRelativeEvidence(sourcePos,targetPos)
%             pos=LearnFunc.CylindricEvidenceGenerator.getPositionEvidence(images,index);

            for d=3:-1:1
                dist(:,:,d)=bsxfun(@minus,sourcePos(d,:)',targetPos(d,:));
            end
            
            evidence(:,:,2)=dist(:,:,1);
            evidence(:,:,1)=sqrt(dist(:,:,2).^2+dist(:,:,3).^2);
        end
        function evidence=getAbsoluteEvidence(pos)
%             pos=LearnFunc.CylindricEvidenceGenerator.getPositionEvidence(images,index);
            relEvi=LearnFunc.CylindricEvidenceGenerator.getRelativeEvidence(pos,pos);
            evidence=repmat(pos,[1 1 size(pos,2)]);
            evidence=permute(evidence,[2,3,1]);
            evidence(:,:,1)=evidence(:,:,1)-relEvi(:,:,2);
            evidence(:,:,2)=evidence(:,:,2)+relEvi(:,:,1);
            evidence=evidence(:,:,1:2);
        end
        function pos=getPositionEvidence(images,index)
            pos=[images.getObject(index).pos];
        end
    end
    
%     methods(Static)
%         function evidence=getEvidenceForImage(data,index,baseClasses)
%             tmpObjects
%         end
%     end
end