classdef OccurrenceLearner<LearnFunc.Learner
    %OCCURRENCELEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract)
        result=calculateStatistics(obj,testData,occEval)
    end
    
    methods
        function obj=OccurrenceLearner(evidenceGenerator)
            obj=obj@LearnFunc.Learner(evidenceGenerator);
        end
        
        function prob=getProbabilityFromEvidence(obj,evidence,fromClass,toClass)
            error('Learner:notImplemented','This method is not implemented.');
        end
    end
end

