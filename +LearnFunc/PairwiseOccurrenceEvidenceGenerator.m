classdef PairwiseOccurrenceEvidenceGenerator<LearnFunc.OccurrenceEvidenceGenerator
    %PAIRWISEOCCURENCEEVIDENCEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=PairwiseOccurrenceEvidenceGenerator(states)
            obj=obj@LearnFunc.OccurrenceEvidenceGenerator(states);
        end       
        
        function pop=getEvidence(obj,data,~)
            classes=data.getClassNames();
            pop=zeros(length(classes),length(classes),length(obj.states),length(obj.states)); %pop(i,j,state_i,state_j)
            popDiag=zeros(length(classes),length(classes),length(obj.states),length(obj.states));

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
        end
    end
end

