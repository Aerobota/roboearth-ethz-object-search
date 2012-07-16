classdef VerticalDistanceEvidenceGenerator<LearnFunc.LocationEvidenceGenerator
    methods(Static,Access='protected')
        function evidence=getAbsoluteEvidence(pos)
            evidence(:,:,1)=pos(ones(length(pos),1),:);
        end
        function evidence=getRelativeEvidence(sourcePos,targetPos)
            evidence(:,:,1)=bsxfun(@minus,sourcePos(1,:)',targetPos(1,:));
        end
        function pos=getPositionEvidence(images,index)
            tmpObjects=images.getObject(index);
            for o=length(tmpObjects):-1:1
                pos(1,o)=mean(tmpObjects(o).polygon.x)/images.getImagesize(index).nrows;
            end
        end
        function pos=getPositionForImage(images,index)
            [tmpX,~]=meshgrid(1:images.getImagesize(index).nrows,1:images.getImagesize(index).ncols);
            tmpX=tmpX'/images.getImagesize(index).nrows;

            pos=tmpX(:)';
        end
    end
    methods(Static)
        function distance=evidence2Distance(evidence)
            distance=abs(evidence);
        end
    end
end