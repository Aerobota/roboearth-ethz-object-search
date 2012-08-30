classdef OccurrenceLearner<LearnFunc.Learner
    %OCCURRENCELEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=OccurrenceLearner(evidenceGenerator)
            obj=obj@LearnFunc.Learner(evidenceGenerator);
        end
    end
end

