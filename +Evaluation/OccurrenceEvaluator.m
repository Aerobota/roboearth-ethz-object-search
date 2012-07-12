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
                searchIndices=testData.className2Index([myNames(i) dependencies.(myNames{i}).parents]);
                evidence=obj.evidenceGenerator.getEvidence(testData,searchIndices,1:length(testData));
                decisions=obj.decisionImpl(dependencies.(myNames{i}));
                disp(searchIndices)
                disp(size(evidence))
                disp(size(decisions))
                error('stop')
            end
            
        end
    end
    
    methods(Access='protected',Abstract)
        decisions=decisionImpl(obj,myDependencies)
    end
    
end

