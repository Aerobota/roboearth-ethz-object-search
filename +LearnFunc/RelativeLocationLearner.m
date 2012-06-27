classdef RelativeLocationLearner<LearnFunc.StructureLearner
    %LOCATIONMUTINF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        evidenceGenerator
    end
    properties(Constant)
        occurenceEngine=LearnFunc.PairwiseOccurrenceMutInf({'0','1+'});
    end
    
    methods
        function obj=RelativeLocationLearner(classes,evidenceGenerator)
            obj=obj@LearnFunc.StructureLearner(classes);
            obj.evidenceGenerator=evidenceGenerator;
        end
        function dependencies=learnStructure(obj,data)
            warning('Not implemented yet')
            samples=obj.evidenceGenerator.orderRelativeEvidenceSamples(data,obj.classes);
            covar=cell(size(samples));
            for i=1:size(samples,2)*size(samples,1)
                if size(samples{i},1)>20
                    covar{i}=cov(samples{i});
                end
            end
            pop=obj.occurenceEngine.occurrenceProbability(data,obj.classes);
            poe=pop(:,:,2,2)./(pop(:,:,2,1)+pop(:,:,2,2));
            dependencies.poe=poe;
            dependencies.cov=covar;
%             samples=obj.getOrderedSamples(data,classes);
        end
    end
%     methods(Access='protected')
%         function samples=getOrderedSamples(obj,data,classes)
%             samples=cell(length(classes),length(classes));
%             for i=1:length(data)
%                 evidence=obj.evidenceGenerator.getRelativeEvidence(data(i))';
%                 
%                 for o=1:length(data(i).annotation.object)
%                     for t=o+1:length(data(i).annotation.object)
%                         indices=find(ismember(classes,{data(i).annotation.object(o).name,data(i).annotation.object(t).name}));
%                         samples{min(indices),max(indices)}(end+1,:,:)=[evidence(o,:);evidence(t,:)];
%                     end
%                 end
%             end
%         end
%     end
end