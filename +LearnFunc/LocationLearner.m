classdef LocationLearner<handle
    %LOCATIONLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='private')
        classes;
    end
    
    methods(Abstract)
        %learnLocations(obj,images);
        CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass);
    end
    
    methods(Abstract,Static)
        evidence=getEvidence(image);
    end
    
    methods(Abstract,Access='protected')
        evaluateOrderedSamples(obj,samples);
    end
    
    methods
        function obj=LocationLearner(classes)
            obj.classes=classes;
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
                evidence=obj.getEvidence(images(i));
                
                for o=1:nObj
                    for t=o+1:nObj
                        index=find(ismember(classes,{images(i).annotation.object(o).name,images(i).annotation.object(t).name}),2);
                        ind1=min(index);
                        ind2=max(index);
                        samples{ind1,ind2}(end+1,:)=evidence(o,t,:);
                    end
                end
            end
        end
    end
end

