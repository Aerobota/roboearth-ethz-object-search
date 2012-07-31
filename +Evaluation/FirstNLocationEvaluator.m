classdef FirstNLocationEvaluator<Evaluation.LocationEvaluationMethod
    %CANDIDATELOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        designation='FirstN'
    end
    
    methods
        function result=scoreClass(~,inRange,~)
            result=find(any(inRange,1),1);
        end
        
        function result=combineResults(~,collectedResults,~)
            data=cat(1,collectedResults{:});
            result=histc(data,unique(data));
            result=cumsum(result)/sum(result);
        end
    end
end

