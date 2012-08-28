classdef LocationLearner<LearnFunc.Learner
    %OCCURRENCELEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract)
        prob=getProbabilityFromEvidence(obj,evidence,fromClass,toClass);
    end
    
    methods
        function obj=LocationLearner(evidenceGenerator)
            obj=obj@LearnFunc.Learner(evidenceGenerator);
        end
    end
end