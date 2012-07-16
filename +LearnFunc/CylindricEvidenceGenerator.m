classdef CylindricEvidenceGenerator<LearnFunc.LocationEvidenceGenerator
    methods(Static,Access='protected')
        function evidence=getRelativeEvidence(sourcePos,targetPos)
            for d=3:-1:1
                dist(:,:,d)=bsxfun(@minus,sourcePos(d,:)',targetPos(d,:));
            end
            
            evidence(:,:,2)=dist(:,:,1);
            evidence(:,:,1)=sqrt(dist(:,:,2).^2+dist(:,:,3).^2);
        end
        function evidence=getAbsoluteEvidence(pos)
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
        function pos=getPositionForImage(images,index)
            depthImage=images.getDepthImage(index);

            [tmpX,tmpY]=meshgrid(1:size(depthImage,1),1:size(depthImage,2));
            tmpX=tmpX';
            tmpY=tmpY';

            pos=[tmpX(:)';tmpY(:)';ones(1,numel(tmpX))];
            pos=images.getCalib(index)\pos;
            
            for d=1:3
                pos(d,:)=pos(d,:).*depthImage(tmpX(:)'+(tmpY(:)'-1)*size(tmpX,1));
            end
        end
    end
    methods(Static)
        function distance=evidence2Distance(evidence)
            distance=sqrt(evidence(:,:,1).^2+evidence(:,:,2).^2);
        end
    end
end