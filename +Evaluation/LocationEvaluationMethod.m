classdef LocationEvaluationMethod
    %LOCATIONEVALUATIONMETHOD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Abstract,Constant)
        designation
    end
    
    properties(Constant)
        nThresh=100
    end
    
    methods(Abstract)
        result=scoreClass(obj,inRange,candidateProb)
        result=combineResults(obj,collectedResults,classesSmall)
    end
end

