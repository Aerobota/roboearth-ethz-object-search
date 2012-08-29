classdef NaiveOccurrenceLearner<LearnFunc.OccurrenceLearner
    %NAIVEOCCURRENCELEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=NaiveOccurrenceLearner(evidenceGenerator)
            obj=obj@LearnFunc.OccurrenceLearner(evidenceGenerator);
        end
        
        function learn(obj,data)
            % get classes and indices of small classes
            classes=data.getClassNames();
            smallIndex=data.className2Index(data.getSmallClassNames());
            largeClassNames=data.getLargeClassNames();
            parentIndices=data.className2Index(largeClassNames);
            
            % for every small class compute 2nd order probability
            for cs=smallIndex
                cp=obj.evidenceGenerator.getEvidence(data,cs,1:length(data),'all');
                cp=cp(:,:,parentIndices);
                boolCP=zeros([2 size(cp,2) size(cp,3)]);
                boolCP(1,:)=cp(1,:);
                boolCP(2,:)=sum(cp(2:end,:),1);
                obj.model.(classes{cs}).parents=largeClassNames;
                obj.model.(classes{cs}).condProb=boolCP./repmat(sum(boolCP,2),[1 size(boolCP,2) 1]);
                obj.model.(classes{cs}).margP=obj.evidenceGenerator.reduceToBool(...
                    obj.evidenceGenerator.getMarginalProbabilities(data,cs,1:length(data)));
            end
        end
    end
end

