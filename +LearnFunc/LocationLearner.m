classdef LocationLearner<LearnFunc.Learner
    %LOCATIONLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
%         bufferedTestData
        bufferFolder
        formatString
    end
    
    properties(Constant)
        bufferPathRoot=fullfile(tempdir,'LocationLearner')
    end
    
    methods
        function obj=LocationLearner(evidenceGenerator)
            obj=obj@LearnFunc.Learner(evidenceGenerator);
        end
        
        function bufferTestData(obj,testData)
            obj.bufferFolder=[];
            if isempty(obj.bufferFolder)
                obj.setupBuffer(length(testData));

                classesSmall=testData.getSmallClassNames();

    %             buffer=cell(1,length(testData));
    %             parfor i=1:length(testData)
                for i=1:4%length(testData)
                    disp(['collecting data for image ' num2str(i)])
                    [goodClasses,buffer.goodObjects]=obj.getGoodClassesAndObjects(testData,i);
                    if ~isempty(goodClasses)
                        [buffer.probVec,buffer.locVec]=obj.probabilityVector(testData,i,classesSmall(goodClasses));
                    end
                    try
                        warning('something about saving is not working')
                    save(fullfile(obj.bufferFolder,['index' num2str(i,obj.formatString) '.mat']),'-struct','buffer');
                    catch
                    end
                end
%                 obj.bufferedTestData=buffer;
            end
        end
        
        function [probVec,locVec,goodObjects]=getBufferedTestData(obj,index)
            warning('need a new loading version')
            probVec=obj.bufferedTestData(index).probVec;
            locVec=obj.bufferedTestData(index).locVec;
            goodObjects=obj.bufferedTestData(index).goodObjects;
        end
        
        function delete(obj)
            disp('mein name ist hase und ich weiss von nichts')
%             disp(obj.bufferFolder)
%             [~,~,~]=rmdir(obj.bufferFolder,'s');
        end
    end
    
    methods(Access='protected')
        function [probVec,locVec]=probabilityVector(obj,data,index,targetClasses)
            evidence=obj.evidenceGenerator.getEvidenceForImage(data,index);

%             goodObjects=true(size(evidence.relEvi,1),1);

            tmpProbVec=cell(1,length(targetClasses));
            parfor c=1:length(targetClasses)
                goodObjects=true(size(evidence.relEvi,1),1);
                for o=size(evidence.relEvi,1):-1:1
                    try
                        tmpProbVec{c}(o,:)=obj.getProbabilityFromEvidence(squeeze(evidence.relEvi(o,:,:)),evidence.names{o},targetClasses{c});
                    catch tmpError
                        if strcmpi(tmpError.identifier,'MATLAB:nonExistentField')
                            goodObjects(o)=false;
                        else
                            disp(tmpError.identifier)
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
        
        function [goodClasses,goodObjects]=getGoodClassesAndObjects(~,data,index)
            tmpClasses=data.getSmallClassNames();
            tmpObjects=data.getObject(index);
            
            goodObjects=struct;
            goodClasses=1:length(tmpClasses);
            goodClassChooser=true(size(goodClasses));
            for c=goodClasses
                tmpChooser=ismember({tmpObjects.name},tmpClasses{c});
                if any(tmpChooser)
                    goodObjects.(tmpClasses{c})=tmpObjects(tmpChooser);
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

