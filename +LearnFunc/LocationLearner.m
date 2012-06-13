classdef LocationLearner<handle
    %LOCATIONLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='private')
        classes;
    end
    methods
        function obj=LocationLearner(classes)
            obj.classes=classes;
        end
    end
    
    methods(Abstract)
        learnLocations(obj,images);
        CPD=getConnectionNodeCPD(obj,fromClass,toClass);
        evidence=adaptEvidence(obj,fromClass,toClass,evidence);
    end
    
end

