classdef LocationEvaluator<Evaluation.Evaluator
    %LOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function result=evaluate(obj,locationLearner,testData,evaluationMethods,maxDistances)
            classesSmall=testData.getSmallClassNames();
            resultCollector=cell(length(testData),length(classesSmall),length(evaluationMethods),length(maxDistances));
            parfor i=1:length(testData)
                disp(['collecting data for image ' num2str(i)])
                [goodClasses,goodObjects]=obj.getGoodClassesAndObjects(testData,i);
                if ~isempty(goodClasses)
                    [probVec,locVec]=obj.probabilityVector(testData,i,locationLearner,classesSmall(goodClasses));
                    tmpResult=cell(1,length(classesSmall),length(evaluationMethods),length(maxDistances));
                    for c=goodClasses
                        for d=1:length(maxDistances)
                            [inRange,candidateProb]=obj.getCandidatePoints(...
                                probVec.(classesSmall{c}),locVec,[goodObjects.(classesSmall{c}).pos],maxDistances(d));
                            for e=1:length(evaluationMethods)
                                tmpResult{1,c,e,d}=evaluationMethods{e}.scoreClass(inRange,candidateProb);
                            end
                        end
                    end
                    resultCollector(i,:,:,:)=tmpResult;
                end
            end
            for e=1:length(evaluationMethods)
                for d=1:length(maxDistances)
                    result.(evaluationMethods{e}.designation){d}=evaluationMethods{e}.combineResults(resultCollector(:,:,e,d),classesSmall);
                end
            end
            result.maxDistances=maxDistances;
        end
    end
    
    methods(Access='protected',Static)
        function [probVec,locVec]=probabilityVector(data,index,locationLearner,targetClasses)
            evidence=locationLearner.evidenceGenerator.getEvidenceForImage(data,index);
            
            tmpProbVec=cell(1,length(targetClasses));
            for c=1:length(targetClasses)
                goodObjects=true(size(evidence.relEvi,1),1);
                for o=size(evidence.relEvi,1):-1:1
                    try
                        probVec.(targetClasses{c})(o,:)=locationLearner.getProbabilityFromEvidence(squeeze(evidence.relEvi(o,:,:)),evidence.names{o},targetClasses{c});
                    catch tmpError
                        if any(strcmpi(tmpError.identifier,{'MATLAB:nonExistentField','MATLAB:nonStrucReference'}))
                            goodObjects(o)=false;
                        else
                            tmpError.rethrow();
                        end
                    end
                end
                probVec.(targetClasses{c})=prod(probVec.(targetClasses{c})(goodObjects,:),1);
            end
            
            for c=1:length(targetClasses)
                if ~isempty(tmpProbVec{c})
                    probVec.(targetClasses{c})=tmpProbVec{c};
                end
            end
            locVec=evidence.absEvi;
        end
        
        function [goodClasses,goodObjects]=getGoodClassesAndObjects(data,index)
            classesSmall=data.getSmallClassNames();
            tmpObjects=data.getObject(index);
            
            goodObjects=struct;
            goodClasses=1:length(classesSmall);
            goodClassChooser=true(size(goodClasses));
            for c=goodClasses
                tmpChooser=ismember({tmpObjects.name},classesSmall{c});
                if any(tmpChooser)
                    goodObjects.(classesSmall{c})=tmpObjects(tmpChooser);
                else
                    goodClassChooser(c)=false;
                end
            end
            
            goodClasses=goodClasses(goodClassChooser);
        end
        
        function [inRange,candidateProb]=getCandidatePoints(probVec,locVec,truePos,maxDistance)
            [probVec,permIndex]=sort(probVec,'descend');
            locVec=locVec(:,permIndex);

            candidatePoints=[];
            candidateProb=[];
            while ~isempty(locVec)
                candidatePoints(:,end+1)=locVec(:,1);
                candidateProb(1,end+1)=probVec(:,1);
                [probVec,locVec]=Evaluation.LocationEvaluator.removeCoveredPoints(...
                    probVec,locVec,candidatePoints(:,end),maxDistance);
            end

            inRange=false(size(truePos,2),size(candidatePoints,2));
            if ~isempty(truePos)
                candidatePoints=permute(candidatePoints,[3 2 1]);
                truePos=permute(truePos,[2 3 1]);
                inRange=sum((truePos(:,ones(1,size(candidatePoints,2)),:)-...
                    candidatePoints(ones(1,size(truePos,1)),:,:)).^2,3)<maxDistance^2;
            end
        end
        
        function [probVec,locVec]=removeCoveredPoints(probVec,locVec,point,maxDistance)
            pointsOutside=sum((point(:,ones(1,size(locVec,2)))-locVec).^2,1)>maxDistance^2;
            locVec=locVec(:,pointsOutside);
            probVec=probVec(:,pointsOutside);
        end
    end
end

