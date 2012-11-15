classdef OccurrenceLearner<LearnFunc.Learner
    %OCCURRENCELEARNER Base class for all occurrence learners
    %   This class has no further functionality but was created for
    %   symmetry with the LearnFunc.LocationLearner class.
    
    methods
        function obj=OccurrenceLearner(evidenceGenerator)
            obj=obj@LearnFunc.Learner(evidenceGenerator);
        end
    end
end

