classdef ScoreLearner<LearnFunc.ParameterLearner
    properties(Constant)
        states={'negative','positive'};
    end
    
    methods
        function obj=ScoreLearner(classes,evidenceGenerator)
            obj=obj@LearnFunc.ParameterLearner(genvarname(classes),evidenceGenerator);
        end
        
        function CPD=getConnectionNodeCPD(obj,network,nodeNumber,fromClass,toClass)
            error('Learner:notImplemented','This function is not implemented yet')
%             CPD(1)=gaussian_CPD(network,nodeNumber(1),'mean',obj.data.(fromClass).(toClass).mean,...
%                 'cov',obj.data.(fromClass).(toClass).cov);
%             CPD(2)=tabular_CPD(network,nodeNumber(2),'CPT',obj.data.(fromClass).(toClass).mixCoeff);
        end
    end
    methods(Access='protected')
        function evaluateOrderedSamples(obj,samples)
            for i=1:length(obj.classes)
                obj.(obj.classes{i}).b=mnrfit(samples{i}(:,1),(samples{i}(:,2)>=0.5)+1);    %index=1: negative; index=2: positive
            end
        end
    end
end