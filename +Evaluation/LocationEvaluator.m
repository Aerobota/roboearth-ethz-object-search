classdef LocationEvaluator<Evaluation.Evaluator
    %LOCATIONEVALUATOR Master Class for Evaluating Location Models
    %   This class implements the EVALUATE method from the abstract
    %   EVALUATOR class and supplies the two static methods
    %   PROBABILITYVECTOR and GETCANDIDATEPOINTS.
    %
    %See also EVALUATION.EVALUATOR,
    %   EVALUATION.LOCATIONEVALUATOR.PROBABILITYVECTOR,
    %   EVALUATION.LOCATIONEVALUATOR.GETCANDIDATEPOINTS
    
    
    methods
        function result=evaluate(obj,testData,locationLearner,evaluationMethods,maxDistances)
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
            result.classes=classesSmall;
        end
    end
    
    methods(Static)
        function [probVec,locVec]=probabilityVector(data,index,locationLearner,targetClasses)
            evidence=locationLearner.evidenceGenerator.getEvidenceForImage(data,index);
            
            tmpProbVec=cell(1,length(targetClasses));
            probVec=struct;
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
                if isfield(probVec,targetClasses{c})
                    probVec.(targetClasses{c})=mean(probVec.(targetClasses{c})(goodObjects,:),1);
                else
                    probVec.(targetClasses{c})=1/size(evidence.absEvi,2)*ones(1,size(evidence.absEvi,2));
                end
            end
            
            for c=1:length(targetClasses)
                if ~isempty(tmpProbVec{c})
                    probVec.(targetClasses{c})=tmpProbVec{c};
                end
            end
            locVec=evidence.absEvi;
        end
        
        function [inRange,candidateProb,candidatePoints]=getCandidatePoints(probVec,locVec,truePos,maxDistance)
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
    end
    
    methods(Static,Access='protected')        
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
        
        function [probVec,locVec]=removeCoveredPoints(probVec,locVec,point,maxDistance)
            pointsOutside=sum((point(:,ones(1,size(locVec,2)))-locVec).^2,1)>maxDistance^2;
            locVec=locVec(:,pointsOutside);
            probVec=probVec(:,pointsOutside);
        end
    end
end

