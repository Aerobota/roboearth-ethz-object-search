classdef ParameterLearner<LearnFunc.Learner
    %PARAMETERLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant)
        minSamples=20
    end
    properties(SetAccess='protected')
        data
        evidenceGenerator
    end
    
    methods(Abstract)
        CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass);
    end
    
    methods(Abstract,Access='protected')
        evaluateOrderedSamples(obj,samples);
    end
    
    methods
        function obj=ParameterLearner(classes,evidenceGenerator)
            obj=obj@LearnFunc.Learner(classes);
            obj.evidenceGenerator=evidenceGenerator;
        end
        function learnParameters(obj,images)
            samples=obj.evidenceGenerator.orderRelativeEvidenceSamples(images,obj.classes);
            obj.evaluateOrderedSamples(samples);
        end
    end
    
end

