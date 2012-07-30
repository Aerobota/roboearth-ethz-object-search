classdef LocationLearner<LearnFunc.Learner
    %LOCATIONLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        bufferFolder
        bufferingComplete
        formatString
        nDataPoints
        classesSmall
    end
    
    properties(Constant)
        bufferPathRoot=fullfile(tempdir,'LocationLearner')
        bufferFileName='index'
    end
    
    methods
        function obj=LocationLearner(evidenceGenerator)
            obj=obj@LearnFunc.Learner(evidenceGenerator);
            obj.bufferingComplete=false;
        end
        
        function bufferTestData(obj,testData)
            if ~obj.bufferingComplete
                obj.setupBuffer(length(testData));
                
                obj.classesSmall=testData.getSmallClassNames();
                obj.nDataPoints=length(testData);
                
                startPoints=1:20:obj.nDataPoints;
                endPoints=[startPoints(2:end)-1 obj.nDataPoints];
                for part=1:length(startPoints)
                    index=startPoints(part):endPoints(part);
                    bufferCollection=cell(1,length(index));
                    parfor i=1:length(index)
                        disp(['collecting data for image ' num2str(index(i))])
                        [goodClasses,bufferCollection{i}.goodObjects]=obj.getGoodClassesAndObjects(testData,index(i));
                        if ~isempty(goodClasses)
                            [bufferCollection{i}.probVec,bufferCollection{i}.locVec]=obj.probabilityVector(testData,index(i),obj.classesSmall(goodClasses));
                        end
                    end
                    for c=1:length(bufferCollection)
                        buffer=bufferCollection{c};
                        save(fullfile(obj.bufferFolder,[obj.bufferFileName num2str(startPoints(part)+c-1,obj.formatString) '.mat']),'-struct','buffer');
                    end
                end
                obj.bufferingComplete=true;
            end
        end
        
        function [probVec,locVec,goodObjects]=getBufferedTestData(obj,index)
            assert(obj.bufferingComplete,'LocationLearner:notBuffered',...
                'No data buffered yet, run bufferTestData to buffer data.')
            buffer=load(fullfile(obj.bufferFolder,[obj.bufferFileName num2str(index,obj.formatString) '.mat']));
%             disp(buffer.goodObjects)
%             disp(fieldnames(buffer))
%             disp(isstruct(buffer.goodObjects))
            goodObjects=buffer.goodObjects;
%             tmpLength=length(fieldnames(goodObjects));
%             disp(tmpLength)
            if ~isempty(fieldnames(goodObjects))
                probVec=buffer.probVec;
                locVec=buffer.locVec;
            else
                probVec=[];
                locVec=[];
            end
        end
    end
    
    methods(Static)
        function clearBuffer()
            [~,~,~]=rmdir(LearnFunc.LocationLearner.bufferPathRoot,'s');
%             if ~isempty(obj.bufferFolder)
%                 disp('kill?')
%                 [~,~,~]=rmdir(obj.bufferFolder,'s');
%             end
        end
    end
    
    methods(Access='protected')
        function [probVec,locVec]=probabilityVector(obj,data,index,targetClasses)
            evidence=obj.evidenceGenerator.getEvidenceForImage(data,index);
            
            tmpProbVec=cell(1,length(targetClasses));
            for c=1:length(targetClasses)
                goodObjects=true(size(evidence.relEvi,1),1);
                for o=size(evidence.relEvi,1):-1:1
                    try
                        probVec.(targetClasses{c})(o,:)=obj.getProbabilityFromEvidence(squeeze(evidence.relEvi(o,:,:)),evidence.names{o},targetClasses{c});
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
        
        function [goodClasses,goodObjects]=getGoodClassesAndObjects(obj,data,index)
            tmpObjects=data.getObject(index);
            
            goodObjects=struct;
            goodClasses=1:length(obj.classesSmall);
            goodClassChooser=true(size(goodClasses));
            for c=goodClasses
                tmpChooser=ismember({tmpObjects.name},obj.classesSmall{c});
                if any(tmpChooser)
                    goodObjects.(obj.classesSmall{c})=tmpObjects(tmpChooser);
                else
                    goodClassChooser(c)=false;
                end
            end
            
            goodClasses=goodClasses(goodClassChooser);
        end
        
        function setupBuffer(obj,dataLength)
            while isempty(obj.bufferFolder) || exist(obj.bufferFolder,'dir')~=7
                tmpFolder=fullfile(obj.bufferPathRoot,char(randperm(6)+96));
                if ~exist(tmpFolder,'dir')
                    obj.bufferFolder=tmpFolder;
                    [~,~,~]=mkdir(obj.bufferFolder);
                end
            end
            obj.formatString=['%0' int2str(floor(log10(dataLength))+1) 'd'];
        end
    end
end

