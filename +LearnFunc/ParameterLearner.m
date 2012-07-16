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
        prob=getProbabilityFromEvidence(obj,evidence,fromClass,toClass);
    end
    
    methods(Abstract,Access='protected')
        evaluateOrderedSamples(obj,samples);
    end
    
    methods
        function obj=ParameterLearner(evidenceGenerator)
            obj.evidenceGenerator=evidenceGenerator;
        end
        function learnParameters(obj,images)
            samples=obj.evidenceGenerator.getEvidence(images,'relative');
            obj.data.samples=samples;
            obj.evaluateOrderedSamples(samples,images.getClassNames);
        end
    end
end

