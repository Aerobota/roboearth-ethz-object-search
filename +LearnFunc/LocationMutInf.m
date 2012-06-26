classdef LocationMutInf<LearnFunc.MutualInformationEngine
    %LOCATIONMUTINF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        evidenceGenerator
    end
    
    methods
        function obj=LocationMutInf(evidenceGenerator)
            obj.evidenceGenerator=evidenceGenerator;
        end
        function mutInf=mutualInformation(obj,samples,classes)
            warning('Not implemented yet')
        end
    end
    
end

