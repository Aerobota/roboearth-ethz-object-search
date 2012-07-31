classdef FirstNLocationEvaluator<Evaluation.LocationEvaluationMethod
    %CANDIDATELOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        designation='FirstN'
    end
    
    methods
        function result=scoreClass(~,inRange,~)
            result=find(any(inRange,1),1);
            if isempty(result)
                result=inf;
            end
        end
        
        function result=combineResults(~,collectedResults,~)
            data=cat(1,collectedResults{:});
            result.nCandidates=unique(data);
            result.tpRate=histc(data,result.nCandidates);
            result.tpRate=cumsum(result.tpRate)/sum(result.tpRate);
        end
    end
end

