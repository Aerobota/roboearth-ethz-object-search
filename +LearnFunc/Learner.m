classdef Learner<handle
    %LEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
%         evidenceMethod
        classes
    end
    methods
        function obj=Learner(classes)%,evidenceMethod)
            obj.classes=genvarname(classes);
%             obj.evidenceMethod=evidenceMethod;
        end
    end
%     methods(Access='protected')
%         function samples=orderEvidenceSamples(obj,classes,images)
%             samples=cell(length(classes),length(classes));
%             for i=1:length(images)
%                 nObj=length(images(i).annotation.object);
%                 evidence=obj.evidenceMethod(images(i));
%                 
%                 for o=1:nObj
%                     for t=o+1:nObj
%                         indo=ismember(classes,images(i).annotation.object(o).name);
%                         indt=ismember(classes,images(i).annotation.object(t).name);
%                         samples{indo,indt}(end+1,:)=evidence(o,t,:);
%                         samples{indt,indo}(end+1,:)=evidence(t,o,:);
%                     end
%                 end
%             end
%         end
%     end
    
end

