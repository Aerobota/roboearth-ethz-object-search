classdef CostOptimalOccurrenceEvaluator<Evaluation.OccurrenceEvaluator
    %COSTOPTIMALEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj=CostOptimalOccurrenceEvaluator(evidenceGenerator)
            obj=obj@Evaluation.OccurrenceEvaluator(evidenceGenerator);
        end
    end
    methods(Access='protected')
        function decisions=decisionImpl(~,myDependencies)
            decisions=myDependencies.optimalDecision;
        end
    end
    
end

