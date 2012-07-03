classdef LocationEvidenceGenerator<LearnFunc.EvidenceGenerator
    %LOCATIONEVIDENCEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function evidence=getEvidence(obj,data,classes,varargin)
            if length(varargin)==1
                if strcmpi(varargin{1},'relative')
                    evidence=obj.orderRelativeEvidenceSamples(data,classes);
                    return
                elseif strcmpi(varargin{1},'absolute')
                    evidence=obj.orderAbsoluteEvidenceSamples(data,classes);
                    return
                end
            end
            error('LocationEvidenceGenerator:getEvidence:wrongInput',...
                'The varargin argument has to be ''relative'' or ''absolute''.')
        end
    end
    
    methods(Abstract,Static,Access='protected')
        evidence=getRelativeEvidence(image)
        evidence=getAbsoluteEvidence(image)
    end
    
    methods(Access='protected')
        function samples=orderRelativeEvidenceSamples(obj,images,classes)
            name2ind=LearnFunc.EvidenceGenerator.generateIndexLookup(classes);
            samples=cell(length(classes),length(classes));
            for i=1:length(images)
                evidence=obj.getRelativeEvidence(images.getSubset(i));
                
                objects=images.getObject(i);
                for o=1:length(objects)
                    for t=o+1:length(objects)
                        indo=name2ind.(objects(o).name);
                        indt=name2ind.(objects(t).name);
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
                
                objects=images.getObject(i);
                for o=1:length(objects)
                    for t=o+1:length(objects)
                        indo=name2ind.(objects(o).name);
                        indt=name2ind.(objects(t).name);
                        samples{indo,indt}(end+1,1,:)=evidence(o,o,:);
                        samples{indo,indt}(end,2,:)=evidence(o,t,:);
                        samples{indt,indo}(end+1,1,:)=evidence(t,t,:);
                        samples{indt,indo}(end,2,:)=evidence(t,o,:);
                    end
                end
            end
        end
    end
    
end

