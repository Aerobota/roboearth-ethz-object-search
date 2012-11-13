classdef ThresholdOccurrenceEvaluator<Evaluation.OccurrenceEvaluator
    %THRESHOLDOCCURRENCEEVALUATOR Decides occurrence by thresholding
    %   This class implements the decisionImpl method by comparing the
    %   conditional probability with a set of thresholds.
    
    methods
        function decisions=decisionImpl(obj,myDependencies)
            tmpSize=size(myDependencies.condProb);
            % Make a decision for every threshold and every possibility of
            % observed random variables.
            decisions=ones([length(obj.thresholds),tmpSize(2:end)]);
            % Input the conditional probabilities
            tmpCP=repmat(myDependencies.condProb(2,:),[length(obj.thresholds) ones(1,ndims(decisions)-1)]);
            % Make the decisions by thresholding
            decisions(tmpCP>=repmat(obj.thresholds,[1 size(tmpCP,2)]))=2;
        end
    end
end

