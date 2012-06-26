classdef MutualInformationEngine
    %MUTUALINFORMATIONENGINE Summary of this class goes here
    %   Detailed explanation goes here
    
%     properties(SetAccess='protected')
%     end
    
    methods(Abstract)
        mutInf=mutualInformation(obj,samples,classes)
    end
    
end

