classdef CylindricEvidenceGenerator<LearnFunc.LocationEvidenceGenerator
    %CYLINDRICEVIDENCEGENERATOR Produces relative locations in cylindric coordinates
    %   This class implements LearnFunc.LocationEvidenceGenerator. The
    %   returned evidence is 2-dimensional where the first dimension is the
    %   horizontal distance and the second the height.
    %
    %See also LEARNFUNC.LOCATIONEVIDENCEGENERATOR
    methods(Static,Access='protected')
        function evidence=getRelativeEvidence(sourcePos,targetPos)
            for d=3:-1:1
                dist(:,:,d)=bsxfun(@minus,sourcePos(d,:)',targetPos(d,:));
            end
            
            evidence(:,:,2)=dist(:,:,1);
            evidence(:,:,1)=sqrt(dist(:,:,2).^2+dist(:,:,3).^2);
        end
        function pos=getPositionEvidence(images,index)
            pos=[images.getObject(index).pos];
        end
        function pos=getPositionForImage(images,index)
            pos=images.get3DPositionForImage(index);
        end
    end
end