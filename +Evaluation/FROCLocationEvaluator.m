classdef FROCLocationEvaluator<Evaluation.LocationEvaluator
    %CANDIDATELOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access='private')
        allImages
    end
    
    methods
        function obj=FROCLocationEvaluator(analyseAllImages)
            obj.allImages=analyseAllImages;
        end
    end
    
    methods(Access='protected')
        function [tp,fp,pos,neg]=scoreClass(obj,data,locationLearner,targetClass)
            disp(['running for class ' targetClass])
            
            dataIndices=1:length(data);
            for i=length(data):-1:1
                goodObjects{i}=data.getObject(i);
                goodObjects{i}=goodObjects{i}(ismember({goodObjects{i}.name},targetClass));
                goodData(i)=~isempty(goodObjects{i});
            end
            
            if ~obj.allImages
                dataIndices=dataIndices(goodData);
            end            
            
            nThresh=length(obj.thresholds);
            tp=zeros(nThresh,1);
            fp=zeros(nThresh,1);
            pos=0;
            neg=0;
            
            disp(['counting for ' targetClass])
            
            for i=dataIndices
                disp(['running image ' num2str(i)])
                probVec=obj.probabilityVector(data,i,locationLearner,targetClass);
                locVec=data.get3DPositionForImage(i);
                [probVec,permIndex]=sort(probVec,'descend');
                locVec=locVec(:,permIndex);
                
%                 available=true(size(probVec));
                candidatePoints=[];
                candidateProb=[];
                while ~isempty(locVec)
                    candidatePoints(:,end+1)=locVec(:,1);
                    candidateProb(1,end+1)=probVec(:,1);
                    pointsOutside=sum((candidatePoints(:,end*ones(1,size(locVec,2)))-locVec).^2,1)>obj.maxDistance^2;
                    locVec=locVec(:,pointsOutside);
                    probVec=probVec(:,pointsOutside);
                end
                
                truePoints=[goodObjects{i}.pos];
                
                inRange=false(size(truePoints,2),size(candidatePoints,2));
                if ~isempty(truePoints)
                    candidatePoints=permute(candidatePoints,[3 2 1]);
                    truePoints=permute(truePoints,[2 3 1]);
                    inRange=sum((truePoints(:,ones(1,size(candidatePoints,2)),:)-...
                        candidatePoints(ones(1,size(truePoints,1)),:,:)).^2,3)<obj.maxDistance^2;
                end
                
                for t=1:nThresh
                    tmpInRange=inRange(:,candidateProb>obj.thresholds(t));
                    tp(t)=tp(t)+sum(any(tmpInRange,2),1);
                    fp(t)=fp(t)+sum(~any(tmpInRange,1),2);
                end
                
                pos=pos+length(goodObjects{1});
                neg=neg+1;
            end
        end
    end
    
end

