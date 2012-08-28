classdef CostOptimalOccurrenceEvaluator<Evaluation.OccurrenceEvaluator
    %COSTOPTIMALEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function decisions=decisionImpl(~,myDependencies)
            decisions=myDependencies.optimalDecision;
        end
    end
end

