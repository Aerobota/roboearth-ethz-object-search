classdef EvidenceGenerator
    
    methods(Abstract,Static)
        evidence=getRelativeEvidence(image)
        evidence=getAbsoluteEvidence(image)
    end
    
    methods
        function samples=orderRelativeEvidenceSamples(obj,images,classes)
            name2ind=LearnFunc.EvidenceGenerator.generateIndexLookup(classes);
            samples=cell(length(classes),length(classes));
            for i=1:length(images)
                evidence=obj.getRelativeEvidence(images.getSubset(i));
                
                for o=1:length(images.getObject(i))
                    for t=o+1:length(images.getObject(i))
                        indo=name2ind.(images.getObject(i,o).name);
                        indt=name2ind.(images.getObject(i,o).name);
                        samples{indo,indt}(end+1,:)=evidence(o,t,:);
                        samples{indt,indo}(end+1,:)=evidence(t,o,:);
                    end
                end
            end
        end
        function samples=orderAbsoluteEvidenceSamples(obj,images,classes)
            name2ind=LearnFunc.EvidenceGenerator.generateIndexLookup(classes);
            samples=cell(length(classes),length(classes));
            for i=1:length(images)
                evidence=obj.getAbsoluteEvidence(images.getSubset(i));
                
                for o=1:length(images.getObject(i))
                    for t=o+1:length(images.getObject(i))
                        indo=name2ind.(images.getObject(i,o).name);
                        indt=name2ind.(images.getObject(i,o).name);
                        samples{indo,indt}(end+1,1,:)=evidence(o,o,:);
                        samples{indo,indt}(end,2,:)=evidence(o,t,:);
                        samples{indt,indo}(end+1,1,:)=evidence(t,t,:);
                        samples{indt,indo}(end,2,:)=evidence(t,o,:);
                    end
                end
            end
        end
    end
    methods(Static,Access='protected')
        function name2ind=generateIndexLookup(names)
            for i=1:length(names)
                name2ind.(genvarname(names{i}))=i;
            end
        end
    end
end