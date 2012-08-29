classdef OccurrenceEvidenceGenerator<LearnFunc.EvidenceGenerator
    properties(SetAccess='protected')
        states;
        comparer;
    end
    
    methods(Abstract)
        result=calculateStatistics(obj,testData,occLearner,occEval)
    end
    
    methods
        function obj=OccurrenceEvidenceGenerator(states)
            obj.states=states;
            obj.comparer=obj.generateComparer(obj.states);
        end    
        
        function indices=getStateIndices(obj,counts)
            assert(size(counts,1)==1,'PairwiseProbability:getStateIndices:matrixSize',...
                'Counts has to be a row vector.');

            indices=zeros(length(counts),1);
            for i=1:length(obj.comparer)
                indices(obj.comparer{i}(counts))=i;
            end
            
            assert(length(indices)==length(counts),'Pairwise:Probability:getStateIndices:badComparer',...
                'The states of the pairwise probability comparer are not complete.');
        end
    end
    
    
    methods(Access='protected',Static)
        function comparer=generateComparer(states)
            comparer=cell(length(states),1);
            lastMax=-1;
            
            for s=1:length(states)
                minMax=regexp(states{s},'-','split');
                if length(minMax)==2
                    % 'n-m' case
                    tmp(2,1)=str2double(minMax{2});
                    tmp(1,1)=str2double(minMax{1});
                    lowerBound=min(tmp);
                    upperBound=max(tmp);
                    comparer{s}=@(x) x>=lowerBound & x<=upperBound;
                    thisMin=min(tmp);
                    thisMax=max(tmp);
                else
                    nPlus=regexp(states{s},'+','split');
                    if length(nPlus)==2
                        % 'n+' case
                        lowerBound=str2double(nPlus{1});
                        comparer{s}=@(x) x>=lowerBound;
                        thisMin=nPlus{1};
                        thisMax=inf;
                    else
                        % 'n' case
                        equalValue=str2double(states{s});
                        comparer{s}=@(x) x==equalValue;
                        thisMin=str2double(states{s});
                        thisMax=thisMin;
                    end
                end
                assert(lastMax<thisMin,'PairwiseOccurrenceEvidenceGenerator:badStates',...
                    'The states must be monotonically increasing without overlap.')
                if s==1
                    assert(thisMax==0,'PairwiseOccurrenceEvidenceGenerator:badStates',...
                        'The first state has to be ''0''');
                end
            end
        end
    end
end