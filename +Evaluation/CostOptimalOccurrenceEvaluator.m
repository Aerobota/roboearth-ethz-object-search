classdef CostOptimalOccurrenceEvaluator<Evaluation.OccurrenceEvaluator
    %COSTOPTIMALEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Access='protected')
        function decisions=decisionImpl(~,myDependencies)
            decisions=myDependencies.optimalDecision;
        end
    end
end

