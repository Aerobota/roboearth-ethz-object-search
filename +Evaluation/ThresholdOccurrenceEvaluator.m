classdef ThresholdOccurrenceEvaluator<Evaluation.OccurrenceEvaluator
    %COSTOPTIMALEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
%     properties(SetAccess='protected')
%         thresholds
%     end
    
    methods
%         function obj=ThresholdOccurrenceEvaluator(evidenceGenerator,nrOfThresholds)
%             obj=obj@Evaluation.OccurrenceEvaluator(evidenceGenerator);
%             obj.thresholds=linspace(0,1,nrOfThresholds)';
%         end
        function obj=ThresholdOccurrenceEvaluator(evidenceGenerator)
            obj=obj@Evaluation.OccurrenceEvaluator(evidenceGenerator);
        end
    end
    methods(Access='protected')
        function decisions=decisionImpl(obj,myDependencies)
            tmpSize=size(myDependencies.condProb);
            decisions=ones([length(obj.thresholds),tmpSize(2:end)]);
%             disp(size(decisions));
            tmpCP=repmat(myDependencies.condProb(2,:),[length(obj.thresholds) ones(1,ndims(decisions)-1)]);
%             disp(size(decisions(:,:)))
%             disp(size(repmat(obj.thresholds,[1 size(decisions(:,:),2)])))
            decisions(tmpCP>=repmat(obj.thresholds,[1 size(tmpCP,2)]))=2;
        end
    end
end

