classdef LocationLearner<LearnFunc.Learner
    %LOCATIONLEARNER Base class for location learning
    %   Extends the basic LearnFunc.Learner interface. Especially adds two
    %   methods: getProbabilityFromEvidence, removeParents.
    %
    %See also LEARNFUNC.LOCATIONLEARNER.GETPROBABILITYFROMEVIDENCE,
    %   LEARNFUNC.LOCATIONLEARNER.REMOVEPARENTS
    
    properties
    end
    
    methods(Abstract)
        %PROB=GETPROBABILITYFROMEVIDENCE(OBJ,EVIDENCE,FROMCLASS,TOCLASS)
        %   Returns the probability of each relative location for the given
        %   classes.
        %
        %EVIDENCE is a mxd matrix where each row is an observed relative
        %   location of dimensionality d.
        %
        %FROMCLASS and TOCLASS are strings which specify from which class
        %   to which class the relative locations have been measured.
        %
        %PROB is a mx1 vector with the probability of each observed
        %   relative location.
        prob=getProbabilityFromEvidence(obj,evidence,fromClass,toClass);
    end
    
    methods
        function obj=LocationLearner(evidenceGenerator)
            obj=obj@LearnFunc.Learner(evidenceGenerator);
        end
        
        function removeParents(obj,childClass,toRemove)
            %REMOVEPARENTS(OBJ,CHILDCLASS,TOREMOVE)
            %   Removes a parent from the set of observed classes when
            %   predicting the location of the child class.
            obj.model.(childClass)=rmfield(obj.model.(childClass),toRemove);
        end
    end
end