classdef LocationEvidenceGenerator<LearnFunc.EvidenceGenerator
    %LOCATIONEVIDENCEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function evidence=getEvidence(obj,data,varargin)
            if length(varargin)==1
                if strcmpi(varargin{1},'relative')
                    evidence=obj.orderRelativeEvidenceSamples(data);
                    return
                elseif strcmpi(varargin{1},'absolute')
                    evidence=obj.orderAbsoluteEvidenceSamples(data);
                    return
                end
            end
            error('LocationEvidenceGenerator:getEvidence:wrongInput',...
                'The varargin argument has to be ''relative'' or ''absolute''.')
        end
    end
    
    methods(Abstract,Static,Access='protected')
        evidence=getRelativeEvidence(images,index)
        evidence=getAbsoluteEvidence(images,index)
    end
    
    methods(Access='protected')
        function samples=orderRelativeEvidenceSamples(obj,images)
            classes=images.getClassNames();
            samples=cell(length(classes),length(classes));
            for i=1:length(images)
                evidence=obj.getRelativeEvidence(images,i);
                
                objects=images.getObject(i);
                for o=1:length(objects)
                    for t=o+1:length(objects)
                        indo=images.className2Index(objects(o).name);
                        indt=images.className2Index(objects(t).name);
                        samples{indo,indt}(end+1,:)=evidence(o,t,:);
                        samples{indt,indo}(end+1,:)=evidence(t,o,:);
                    end
                end
            end
        end
        function samples=orderAbsoluteEvidenceSamples(obj,images)
            classes=images.getClassNames();
            samples=cell(length(classes),length(classes));
            for i=1:length(images)
                evidence=obj.getAbsoluteEvidence(images,i);
                
                objects=images.getObject(i);
                for o=1:length(objects)
                    for t=o+1:length(objects)
                        indo=images.className2Index(objects(o).name);
                        indt=images.className2Index(objects(t).name);
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

