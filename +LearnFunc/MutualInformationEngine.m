classdef MutualInformationEngine
    %MUTUALINFORMATIONENGINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        minSamples=20;
    end
    properties(SetAccess='protected')
        evidenceGenerator
    end
    
    methods
        function obj=MutualInformationEngine(evidenceGenerator)
            obj.evidenceGenerator=evidenceGenerator;
        end
    end
    
    methods(Abstract)
        mutInf=mutualInformation(obj,data)
    end
    
end

