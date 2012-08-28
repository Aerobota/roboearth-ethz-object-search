classdef Learner<handle
    %LEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        model
        evidenceGenerator
    end
    
    properties(Constant)
        minSamples=20
    end
    
    methods(Abstract)
        learn(obj,data)
    end
    
    methods
        function obj=Learner(evidenceGenerator)
            obj.evidenceGenerator=evidenceGenerator;
        end
        
        function names=getLearnedClasses(obj)
            names=fieldnames(obj.model);
        end
    end
end

