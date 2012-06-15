classdef CylindricEvidenceGenerator<LearnFunc.EvidenceGenerator
    properties(SetAccess='protected')
        classes;
        heights;
    end
    methods
        function obj=CylindricEvidenceGenerator(classes,heights)
            warning('CylindricEvidenceGenerator:notImplemented',...
                'The class CylindricEvidenceGenerator has not been implemented yet');
            obj.classes=classes;
            obj.heights=heights;
        end
    end
    methods(Static)
        function evidence=getEvidence(image)
            nObj=length(image.annotation.object);
            pos=zeros(2,nObj);
            for o=1:nObj
                pos(:,o)=[mean(image.annotation.object(o).polygon.x/image.annotation.imagesize.ncols);...
                    mean(image.annotation.object(o).polygon.y/image.annotation.imagesize.nrows)];
            end

            evidence(:,:,2)=pos(2*ones(nObj,1),:)-pos(2*ones(nObj,1),:)';
            evidence(:,:,1)=abs(pos(ones(nObj,1),:)-pos(ones(nObj,1),:)');
        end
    end
end