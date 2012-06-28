classdef MutualInformationEngine
    %MUTUALINFORMATIONENGINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        minSamples=20;
    end
    
    methods(Abstract)
        mutInf=mutualInformation(obj,data,classes)
    end
    
end

