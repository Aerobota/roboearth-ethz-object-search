classdef Evaluator
    %EVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        nThresh=100
    end
    
    methods(Abstract)
        result=evaluate(testData,learner)
    end
    
end

