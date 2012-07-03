classdef LocationMutInf<LearnFunc.MutualInformationEngine
    %LOCATIONMUTINF Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=LocationMutInf(evidenceGenerator)
            obj=obj@LearnFunc.MutualInformationEngine(evidenceGenerator);
        end
        function mutInf=mutualInformation(obj,data,classes)
            samples=obj.evidenceGenerator.getEvidence(data,classes,'absolute');
            mutInf=zeros(size(samples));
            for i=1:size(mutInf,1)
                for j=1:size(mutInf,2)
                    if size(samples{i,j},1)<obj.minSamples
                        mutInf(i,j)=NaN;
                    else
                        for d=1:size(samples{i,j},3)
                            rhoIJ=corrcoef(samples{i,j}(:,1:2,d));
                            mutInf(i,j)=mutInf(i,j)-size(samples,1)/2*...
                                log(1-rhoIJ(1,2)^2);
                        end
                    end
                end
            end
        end
    end
    
end

