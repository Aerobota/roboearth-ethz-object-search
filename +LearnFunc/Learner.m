classdef Learner<handle
    %LEARNER Base class for all learners
    %   Defines a few commonalities between the learner classes.
    %
    %OBJ=LEARNER(EVIDENCEGENERATOR)
    %   The standard constructor for all learner classes. An evidence
    %   generator is always necessary and is assigned during construction.
    
    properties(SetAccess='protected')
        model
        evidenceGenerator
    end
    
    properties(Constant)
        minSamples=20
    end
    
    methods(Abstract)
        learn(obj,data)
    end
    
    methods
        function obj=Learner(evidenceGenerator)
            obj.evidenceGenerator=evidenceGenerator;
        end
        
        function names=getLearnedClasses(obj)
            %NAMES=GETLEARNEDCLASSES(OBJ)
            %   Returns the names of all classes for which something was
            %   learned.
            names=fieldnames(obj.model);
        end
    end
end

