classdef ParameterLearner<LearnFunc.Learner
    %PARAMETERLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant)
        minSamples=20;
    end
    properties(SetAccess='protected')
        data;
    end
    
    methods(Abstract)
        CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass);
    end
    
    methods(Abstract,Access='protected')
        evaluateOrderedSamples(obj,samples);
    end
    
    methods
        function obj=ParameterLearner(classes,evidenceMethod)
            obj=obj@LearnFunc.Learner(classes,evidenceMethod);
        end
        function learnLocations(obj,images)
            samples=obj.orderEvidenceSamples(obj.classes,images);
            obj.evaluateOrderedSamples(samples);
        end
    end
    
end

