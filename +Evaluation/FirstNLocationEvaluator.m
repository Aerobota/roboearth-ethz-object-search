classdef FirstNLocationEvaluator<Evaluation.LocationEvaluationMethod
    %FIRSTNLOCATIONEVALUATOR Evaluation method for the search task
    %   This can be used to gather the information used to plot search task
    %   results. This is a LOCATIONEVALUATIONMETHOD and is used in
    %   conjunction with the LOCATIONEVALUATOR.
    %
    %   See also EVALUATION.LOCATIONEVALUATOR.
    
    properties(Constant)
        designation='FirstN'
    end
    
    methods
        function result=scoreClass(~,inRange,~)
            % Get the index of the first candidate point that is in range
            result=find(any(inRange,1),1);
            % If none is in range the result is infinity
            if isempty(result)
                result=inf;
            end
        end
        
        function result=combineResults(~,collectedResults,~)
            % For every class, find all unique data points and make a
            % count the occurrence of each data point
            for c=size(collectedResults,2):-1:1
                data=cat(1,collectedResults{:,c});
                result.nCandidates{c}=unique(data);
                result.tp{c}=histc(data,result.nCandidates{c});
            end
        end
    end
end

