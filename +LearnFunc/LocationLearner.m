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
        
        function removeParents(obj,childClass,toRemove)
            obj.model.(childClass)=rmfield(obj.model.(childClass),toRemove);
        end
    end
end