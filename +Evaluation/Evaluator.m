classdef Evaluator
    %EVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        thresholds=linspace(0,1,200)';
    end
    
    methods(Abstract)
        result=evaluate(testData,learner)
    end
    
end

