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
%             classesSmall=testData.getSmallClassNames();
            
            resultCollector=cell(locationLearner.nDataPoints,length(locationLearner.classesSmall));
%             warning('only computing the first 20 images')
            parfor i=1:locationLearner.nDataPoints
                disp(['collecting data for image ' num2str(i)])
                [probVec,locVec,goodObjects]=locationLearner.getBufferedTestData(i);
                goodClasses=1:length(locationLearner.classesSmall);
                goodClasses=goodClasses(ismember(locationLearner.classesSmall,fieldnames(probVec)));
%                 [goodClasses,goodObjects]=obj.getGoodClassesAndObjects(testData,i);
                if ~isempty(goodClasses)
%                     [probVecCollection,tmpEvidence]=obj.probabilityVector(testData,i,locationLearner,classesSmall(goodClasses));
                    tmpResult=cell(1,length(locationLearner.classesSmall));
                    for c=goodClasses
                        [inRange,candidateProb]=obj.getCandidatePoints(...
                            probVec.(locationLearner.classesSmall{c}),locVec,[goodObjects.(locationLearner.classesSmall{c}).pos]);
                        tmpResult{1,c}=obj.scoreClass(inRange,candidateProb);
                    end
                    resultCollector(i,:)=tmpResult;
                end
            end
            
            result=obj.combineResults(resultCollector,locationLearner.classesSmall);
%             classesSmall=testData.getSmallClassNames();
%             
%             truePos=cell(1,length(classesSmall));
% %             falsePos=cell(1,length(classesSmall));
%             threshold=cell(1,length(classesSmall));
%             positive=[];
%             negative=[];
%             
%             parfor c=1:length(classesSmall)
%                 [truePos{c},threshold{c},positive(1,c),negative(1,c)]=...
%                     obj.scoreClass(testData,locationLearner,classesSmall{c});
%             end
%             
%             warning('baseline is just a dummy function')
%             tmpBaseline=Evaluation.EvaluationData(classesSmall,...
%                 [0;sum(positive,2)],[0;sum(negative,2)],sum(positive,2),sum(negative,2));
%             
%             for c=length(classesSmall):-1:1
%                 [pcTP(:,c),pcFP(:,c)]=obj.reduceEvidence(truePos{c},threshold{c});
%             end
%             result.perClass=Evaluation.EvaluationData(classesSmall,...
%                 pcTP,pcFP,positive,negative,tmpBaseline);
%             
%             [cumTP,cumFP]=obj.reduceEvidence(vertcat(truePos{:}),vertcat(threshold{:}));
%             
%             result.cummulative=Evaluation.EvaluationData(classesSmall,...
%                 cumTP,cumFP,sum(positive,2),sum(negative,2),tmpBaseline);
        end
    end
    
    methods(Access='protected')
%         function [probVec,evidence]=probabilityVector(~,data,index,locationLearner,targetClasses)
%             evidence=locationLearner.evidenceGenerator.getEvidenceForImage(data,index);
% 
% %             probVec=zeros(size(evidence.relEvi,1),size(evidence.relEvi,2));
%             goodObjects=true(size(evidence.relEvi,1),1);
% 
%             for c=1:length(targetClasses)
%                 for o=size(evidence.relEvi,1):-1:1
%                     try
%                         probVec.(targetClasses{c})(o,:)=locationLearner.getProbabilityFromEvidence(squeeze(evidence.relEvi(o,:,:)),evidence.names{o},targetClasses{c});
%                     catch tmpError
%                         if strcmpi(tmpError.identifier,'MATLAB:nonExistentField')
%                             goodObjects(o)=false;
%                         else
%                             disp(tmpError.identifier)
%                             tmpError.rethrow();
%                         end
%                     end
%                 end
%                 probVec.(targetClasses{c})=prod(probVec.(targetClasses{c})(goodObjects,:),1);
%             end
% 
%         end
        
        
        
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

%             truePoints=[goodObjects{i}.pos];

            inRange=false(size(truePos,2),size(candidatePoints,2));
            if ~isempty(truePos)
                candidatePoints=permute(candidatePoints,[3 2 1]);
                truePos=permute(truePos,[2 3 1]);
                inRange=sum((truePos(:,ones(1,size(candidatePoints,2)),:)-...
                    candidatePoints(ones(1,size(truePos,1)),:,:)).^2,3)<obj.maxDistance^2;
%                 inRange=inRange&(cumsum(inRange,2)==1|inRange==0);
            end
        end
        
%         function [goodClasses,goodObjects]=getGoodClassesAndObjects(~,data,index)
%             tmpClasses=data.getSmallClassNames();
%             tmpObjects=data.getObject(index);
%             
%             goodObjects=cell(1,length(tmpObjects));
%             goodClasses=1:length(tmpClasses);
%             goodClassChooser=true(size(goodClasses));
%             for c=goodClasses
%                 goodObjects{c}=tmpObjects(ismember({tmpObjects.name},tmpClasses{c}));
%                 if isempty(goodObjects{c})
%                     goodClassChooser(c)=false;
%                 end
%             end
%             
%             goodClasses=goodClasses(goodClassChooser);
%             
% %             dataIndices=1:length(data);
% %             for i=length(data):-1:1
% %                 goodObjects{i}=data.getObject(index);
% %                 goodObjects{i}=goodObjects{i}(ismember({goodObjects{i}.name},targetClass));
% %                 goodData(i)=~isempty(goodObjects{i});
% %             end
% %             
% %             if ~obj.allImages
% %                 dataIndices=dataIndices(goodData);
% %             end   
%         end
    end
end

