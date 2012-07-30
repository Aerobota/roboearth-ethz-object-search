classdef LocationEvaluator<Evaluation.Evaluator
    %LOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        maxDistance=0.5;
    end
    
    properties(Access='protected')
        allImages
    end
    
    methods(Abstract,Access='protected')
%         [tp,prob,pos,neg]=scoreClass(obj,data,locationLearner,targetClass)
        result=scoreClass(obj,inRange,candidateProb)
        result=combineResults(obj,collectedResults,classesSmall)
    end
    
    methods
        function obj=LocationEvaluator(analyseAllImages)
            obj.allImages=analyseAllImages;
        end
        
        function result=evaluate(obj,locationLearner)
            resultCollector=cell(locationLearner.nDataPoints,length(locationLearner.classesSmall));
%             parfor i=1:locationLearner.nDataPoints
            for i=1:10
                disp(['collecting data for image ' num2str(i)])
                [probVec,locVec,goodObjects]=locationLearner.getBufferedTestData(i);
                if isstruct(probVec)
                    goodClasses=1:length(locationLearner.classesSmall);
                    goodClasses=goodClasses(ismember(locationLearner.classesSmall,fieldnames(probVec)));
                    if ~isempty(goodClasses)
                        tmpResult=cell(1,length(locationLearner.classesSmall));
                        for c=goodClasses
                            [inRange,candidateProb]=obj.getCandidatePoints(...
                                probVec.(locationLearner.classesSmall{c}),locVec,[goodObjects.(locationLearner.classesSmall{c}).pos]);
                            tmpResult{1,c}=obj.scoreClass(inRange,candidateProb);
                        end
                        resultCollector(i,:)=tmpResult;
                    end
                end
            end
            
            result=obj.combineResults(resultCollector,locationLearner.classesSmall);
        end
    end
    
    methods(Access='protected')
        function [inRange,candidateProb]=getCandidatePoints(obj,probVec,locVec,truePos)
            [probVec,permIndex]=sort(probVec,'descend');
            locVec=locVec(:,permIndex);

            candidatePoints=[];
            candidateProb=[];
            while ~isempty(locVec)
                candidatePoints(:,end+1)=locVec(:,1);
                candidateProb(1,end+1)=probVec(:,1);
                pointsOutside=sum((candidatePoints(:,end*ones(1,size(locVec,2)))-locVec).^2,1)>obj.maxDistance^2;
                locVec=locVec(:,pointsOutside);
                probVec=probVec(:,pointsOutside);
            end

            inRange=false(size(truePos,2),size(candidatePoints,2));
            if ~isempty(truePos)
                candidatePoints=permute(candidatePoints,[3 2 1]);
                truePos=permute(truePos,[2 3 1]);
                inRange=sum((truePos(:,ones(1,size(candidatePoints,2)),:)-...
                    candidatePoints(ones(1,size(truePos,1)),:,:)).^2,3)<obj.maxDistance^2;
            end
        end
    end
end

