classdef EvidenceGenerator
    
    methods(Abstract,Static)
        evidence=getRelativeEvidence(image)
        evidence=getAbsoluteEvidence(image)
    end
    
    methods
        function samples=orderRelativeEvidenceSamples(obj,images,classes)
            samples=cell(length(classes),length(classes));
            for i=1:length(images)
%                 nObj=length(images(i).annotation.object);
                evidence=obj.getRelativeEvidence(images(i));
                
                for o=1:length(images(i).annotation.object)
                    for t=o+1:length(images(i).annotation.object)
                        indo=ismember(classes,images(i).annotation.object(o).name);
                        indt=ismember(classes,images(i).annotation.object(t).name);
                        samples{indo,indt}(end+1,:)=evidence(o,t,:);
                        samples{indt,indo}(end+1,:)=evidence(t,o,:);
                    end
                end
            end
        end
        function samples=orderAbsoluteEvidenceSamples(obj,images,classes)
            samples=cell(1,length(classes));
            for i=1:length(images)
%                 nObj=length(images(i).annotation.object);
                evidence=obj.getAbsoluteEvidence(images(i));
                
                for o=1:length(images(i).annotation.object)
                    ind=ismember(classes,images(i).annotation.object(o).name);
                    samples{ind}(:,end+1)=evidence(:,o);
                end
            end
        end
    end
end