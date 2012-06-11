classdef PairwiseProbability
    %PAIRWISEPROBABILITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        states;
        comparer;
    end
    
    methods
        function obj=PairwiseProbability(states)
            obj.states=states;
            obj.comparer=obj.generateComparer(obj.states);
        
        end
        
        function pop=occurenceProbability(obj,samples,classes)
            %states={'0','1','2+'};
            pop=zeros(length(classes),length(classes),length(obj.states),length(obj.states)); %pop(i,j,state_i,state_j)
            popDiag=zeros(length(classes),length(classes),length(obj.states),length(obj.states));

            nSamples=length(samples);

            if isrow(classes)
                classes=classes';
            end

            for s=1:nSamples
                objects={samples(s).annotation.object.name}';
                counts=zeros(1,length(classes));
                for o=1:length(objects)
                    [~,id]=ismember(objects(o),classes);
                    counts(id)=counts(id)+1;
                end
                
                cBins=obj.getStateIndices(counts);
                cBinsMinus1=obj.getStateIndices(max(counts-1,0));

                for i=1:length(classes)
                    %popDiag=incrementProbability(popDiag,i,i,counts(i),max(counts(i)-1,0));
                    popDiag(i,i,cBins(i),cBinsMinus1(i))=popDiag(i,i,cBins(i),cBinsMinus1(i))+1;
                    for j=i+1:length(classes)
                        %pop=incrementProbability(pop,i,j,counts(i),counts(j));
                        pop(i,j,cBins(i),cBins(j))=pop(i,j,cBins(i),cBins(j))+1;
                    end
                end
            end

            pop=pop+permute(pop,[2 1 4 3])+popDiag;

            pop=pop/nSamples;
        end
    end
    methods(Static)
        function pmi=mutualInformation(pop)
            margP=zeros(size(pop,1),size(pop,3));
            for i=1:size(margP,1)
                margP(i,:)=sum(squeeze(pop(i,i,:,:)),2);
            end

            pmi=zeros(size(pop,1),size(pop,2));

            for i=1:size(pmi,1)
                for j=i+1:size(pmi,1)
                    pmi(i,j)=sum(sum(squeeze(pop(i,j,:,:)).*log((squeeze(pop(i,j,:,:))+eps)./(margP(i,:)'*margP(j,:)+eps))));
                end
            end
        end
    end
    methods(Access='protected')
        function indices=getStateIndices(obj,counts)
            assert(isrow(counts),'PairwiseProbability:getStateIndices:matrixSize',...
            'Counts has to be a row vector.');
            logical=cell2mat(cellfun(@(x) x(counts),obj.comparer,'UniformOutput',false));
            [indices,~]=find(logical);
        end
    end
    methods(Access='protected',Static)
        function comparer=generateComparer(states)
            comparer=cell(length(states),1);
            
            for s=1:length(states)
                minMax=regexp(states{s},'-','split');
                if length(minMax)==2
                    if isnan(str2double(minMax{1}))
                        % '-n' case
                        comparer{s}=@(x) x<=str2double(minMax{2});
                        continue;
                    end
                    
                    % 'n-m' case
                    tmp(2,1)=str2double(minMax{2});
                    tmp(1,1)=str2double(minMax{1});
                    comparer{s}=@(x) x>=min(tmp) & x<=max(tmp);
                    continue;
                end
                
                nPlus=regexp(states{s},'+','split');
                if length(nPlus)==2
                    % 'n+' case
                    comparer{s}=@(x) x>=str2double(nPlus{1});
                    continue;
                end
                
                % 'n' case
                comparer{s}=@(x) x==str2double(states{s});
            end
        end
    end
end

