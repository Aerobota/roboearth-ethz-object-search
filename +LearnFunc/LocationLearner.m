classdef LocationLearner<LearnFunc.Learner
    %LOCATIONLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        bufferFolder
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
        end
        
        function bufferTestData(obj,testData)
            if isempty(obj.bufferFolder)
                obj.setupBuffer(length(testData));
                
                obj.classesSmall=testData.getSmallClassNames();
                obj.nDataPoints=length(testData);
                
                for i=1:length(testData)
                    disp(['collecting data for image ' num2str(i)])
                    buffer=struct;
                    [goodClasses,buffer.goodObjects]=obj.getGoodClassesAndObjects(testData,i);
                    if ~isempty(goodClasses)
                        [buffer.probVec,buffer.locVec]=obj.probabilityVector(testData,i,obj.classesSmall(goodClasses));
                    end
                    save(fullfile(obj.bufferFolder,[obj.bufferFileName num2str(i,obj.formatString) '.mat']),'buffer');
                end
            end
        end
        
        function [probVec,locVec,goodObjects]=getBufferedTestData(obj,index)
            assert(~isempty(obj.bufferFolder),'LocationLearner:notBuffered',...
                'No data buffered yet, run bufferTestData to buffer data.')
            load(fullfile(obj.bufferFolder,[obj.bufferFileName num2str(index,obj.formatString) '.mat']),'buffer');
            probVec=buffer.probVec;
            locVec=buffer.locVec;
            goodObjects=buffer.goodObjects;
        end
        
        function delete(obj)
            [~,~,~]=rmdir(obj.bufferFolder,'s');
        end
    end
    
    methods(Access='protected')
        function [probVec,locVec]=probabilityVector(obj,data,index,targetClasses)
            evidence=obj.evidenceGenerator.getEvidenceForImage(data,index);

            tmpProbVec=cell(1,length(targetClasses));
            parfor c=1:length(targetClasses)
                goodObjects=true(size(evidence.relEvi,1),1);
                for o=size(evidence.relEvi,1):-1:1
                    try
                        tmpProbVec{c}(o,:)=obj.getProbabilityFromEvidence(squeeze(evidence.relEvi(o,:,:)),evidence.names{o},targetClasses{c});
                    catch tmpError
                        if any(strcmpi(tmpError.identifier,{'MATLAB:nonExistentField','MATLAB:nonStrucReference'}))
                            goodObjects(o)=false;
                        else
                            tmpError.rethrow();
                        end
                    end
                end
                tmpProbVec{c}=prod(tmpProbVec{c}(goodObjects,:),1);
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
            while isempty(obj.bufferFolder)
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

