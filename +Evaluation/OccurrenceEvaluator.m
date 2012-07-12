classdef OccurrenceEvaluator
    %OCCURRENCEEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        evidenceGenerator
    end
    
    methods
        function obj=OccurrenceEvaluator(evidenceGenerator)
            obj.evidenceGenerator=evidenceGenerator;
        end
        
        function [tpRate,fpRate]=evaluateROC(obj,testData,dependencies)
            myNames=fieldnames(dependencies);
            
            for i=1:length(myNames)
                
            end
            
        end
    end
    
    methods(Access='protected',Abstract)
        decisions=decisionImpl(obj,myDependencies)
    end
    
end

