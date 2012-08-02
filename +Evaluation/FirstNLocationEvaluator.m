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
            for c=size(collectedResults,2):-1:1
                data=cat(1,collectedResults{:,c});
                result.nCandidates{c}=unique(data);
                result.tp{c}=histc(data,result.nCandidates{c});
            end
        end
    end
end

