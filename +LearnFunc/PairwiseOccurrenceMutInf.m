classdef PairwiseOccurrenceMutInf<LearnFunc.MutualInformationEngine
    %PAIRWISEPROBABILITY Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=PairwiseOccurrenceMutInf(evidenceGenerator)
            obj=obj@LearnFunc.MutualInformationEngine(evidenceGenerator);
        end
        
        function pmi=mutualInformation(obj,data,classes)
            samples=obj.evidenceGenerator.getEvidence(data,classes);
            pop=samples/sum(sum(samples(1,1,:,:)));
            
            margP=zeros(size(pop,1),size(pop,3));
            for i=1:size(margP,1)
                margP(i,:)=sum(squeeze(pop(i,i,:,:)),2);
            end

            pmi=zeros(size(pop,1),size(pop,2));

            for i=1:size(pmi,1)
                for j=1:size(pmi,1)
                    pmi(i,j)=sum(sum(squeeze(pop(i,j,:,:)).*log((squeeze(pop(i,j,:,:))+eps)./(margP(i,:)'*margP(j,:)+eps))));
                end
            end
        end
    end
    
end

