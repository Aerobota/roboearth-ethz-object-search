classdef CylindricEvidenceGenerator<LearnFunc.EvidenceGenerator
%     properties(SetAccess='protected')
%         classes;
%     end
%     methods
%         function obj=CylindricEvidenceGenerator()
%             warning('CylindricEvidenceGenerator:notImplemented',...
%                 'The class CylindricEvidenceGenerator has not been implemented yet');
% %             obj.classes=classes;
%         end
%     end
    methods(Static)
        function evidence=getEvidence(image)
            nObj=length(image.annotation.object);
            %pos=zeros(2,nObj);
            for o=length(image.annotation.object):-1:1
                pos(:,o)=[image.annotation.object(o).pos(1);image.annotation.object(o).pos(2);...
                    image.annotation.object(o).pos(3)];
            end

            for d=3:-1:1
                dist(:,:,d)=pos(d*ones(nObj,1),:)-pos(d*ones(nObj,1),:)';
            end
            
            evidence(:,:,2)=dist(:,:,3);
            evidence(:,:,1)=sqrt(dist(:,:,1).^2+dist(:,:,2).^2);
        end
    end
end