classdef Evaluator
    %EVALUATOR Base class for evaluators
    %   This is the common base class for all classes evaluating a learned
    %   model.
    
    properties(Constant)
        nThresh=100
    end
    
    methods(Abstract)
        result=evaluate(testData,learner)
    end
    
end

