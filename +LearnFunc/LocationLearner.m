classdef LocationLearner<handle
    %LOCATIONLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='private')
        classes;
        evidenceGenerator;
    end
    
    methods(Abstract)
        CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass);
    end
    
    methods(Abstract,Access='protected')
        evaluateOrderedSamples(obj,samples);
    end
    
    methods
        function obj=LocationLearner(classes,evidenceGenerator)
            obj.classes=classes;
            obj.evidenceGenerator=evidenceGenerator;
        end
        function learnLocations(obj,images)
            samples=obj.orderEvidenceSamples(obj.classes,images);
            obj.evaluateOrderedSamples(samples);
        end
    end
    
    methods(Access='private')
        function samples=orderEvidenceSamples(obj,classes,images)
            samples=cell(length(classes),length(classes));
            for i=1:length(images)
                nObj=length(images(i).annotation.object);
                evidence=obj.evidenceGenerator.getEvidence(images(i));
                
                for o=1:nObj
                    for t=o+1:nObj
                        indo=ismember(classes,images(i).annotation.object(o).name);
                        indt=ismember(classes,images(i).annotation.object(t).name);
                        samples{indo,indt}(end+1,:)=evidence(o,t,:);
                        samples{indt,indo}(end+1,:)=evidence(t,o,:);
                    end
                end
            end
        end
    end
end

