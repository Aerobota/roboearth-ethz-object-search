classdef PairwiseOccurrenceEvidenceGenerator<LearnFunc.OccurrenceEvidenceGenerator
    %PAIRWISEOCCURENCEEVIDENCEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
%     properties(SetAccess='protected')
%         states;
%         comparer;
%     end
    
    methods
        function obj=PairwiseOccurrenceEvidenceGenerator(states)
            obj=obj@LearnFunc.OccurrenceEvidenceGenerator(states);
%             obj.states=states;
%             obj.comparer=obj.generateComparer(obj.states);
        end       
        
        function pop=getEvidence(obj,data,~)
            classes=data.getClassNames();
            pop=zeros(length(classes),length(classes),length(obj.states),length(obj.states)); %pop(i,j,state_i,state_j)
            popDiag=zeros(length(classes),length(classes),length(obj.states),length(obj.states));
            
%             name2ind=LearnFunc.EvidenceGenerator.generateIndexLookup(classes);

            nSamples=length(data);

            for s=1:nSamples
                objects={data.getObject(s).name}';
                counts=zeros(1,length(classes));
                for o=1:length(objects)
                    id=data.className2Index(objects{o});
                    counts(id)=counts(id)+1;
                end
                cBins=obj.getStateIndices(counts);
                cBinsMinus1=obj.getStateIndices(max(counts-1,0));

                for i=1:length(classes)
                    popDiag(i,i,cBins(i),cBinsMinus1(i))=popDiag(i,i,cBins(i),cBinsMinus1(i))+1;
                    for j=i+1:length(classes)
                        pop(i,j,cBins(i),cBins(j))=pop(i,j,cBins(i),cBins(j))+1;
                    end
                end
            end

            pop=pop+permute(pop,[2 1 4 3])+popDiag;

%             pop=pop/nSamples;
        end
        
%         function indices=getStateIndices(obj,counts)
%             assert(size(counts,1)==1,'PairwiseProbability:getStateIndices:matrixSize',...
%                 'Counts has to be a row vector.');
%             logical=cell2mat(cellfun(@(x) x(counts),obj.comparer,'UniformOutput',false));
%             [indices,~]=find(logical);
%             assert(length(indices)==length(counts),'Pairwise:Probability:getStateIndices:badComparer',...
%                 'The states of the pairwise probability comparer are not complete.');
%         end
%     end
%     methods(Access='protected',Static)
%         function comparer=generateComparer(states)
%             comparer=cell(length(states),1);
%             lastMax=-1;
%             
%             for s=1:length(states)
%                 minMax=regexp(states{s},'-','split');
%                 if length(minMax)==2
% %                     if isnan(str2double(minMax{1}))
% %                         % '-n' case
% %                         comparer{s}=@(x) x<=str2double(minMax{2});
% %                         thisMin=0;
% %                         thisMax=minMax{2};
% %                     else
%                         % 'n-m' case
%                     tmp(2,1)=str2double(minMax{2});
%                     tmp(1,1)=str2double(minMax{1});
%                     comparer{s}=@(x) x>=min(tmp) & x<=max(tmp);
%                     thisMin=min(tmp);
%                     thisMax=max(tmp);
% %                     end
%                 else
%                     nPlus=regexp(states{s},'+','split');
%                     if length(nPlus)==2
%                         % 'n+' case
%                         comparer{s}=@(x) x>=str2double(nPlus{1});
%                         thisMin=nPlus{1};
%                         thisMax=inf;
%                     else
%                         % 'n' case
%                         comparer{s}=@(x) x==str2double(states{s});
%                         thisMin=str2double(states{s});
%                         thisMax=thisMin;
%                     end
%                 end
%                 assert(lastMax<thisMin,'PairwiseOccurrenceEvidenceGenerator:badStates',...
%                     'The states must be monotonically increasing without overlap.')
%                 if s==1
%                     assert(thisMax==0,'PairwiseOccurrenceEvidenceGenerator:badStates',...
%                         'The first state has to be ''0''');
%                 end
%             end
%         end
    end
end
