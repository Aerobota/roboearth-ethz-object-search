classdef SunDataStructure<DataHandlers.DataStructure
    %SUNDATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access='protected')
        myObjectFolder
    end
    
    properties(Constant)
        imageFolder='Images'
        catFileName='sun09_objectCategories.mat'
        trainSet='raining'
        testSet='est'
        gt={'Dt' 'sun09_groundTruth'}
        det={'DdetectorT' 'sun09_detectorOutputs'}
    end
    
    methods
        function obj=SunDataStructure(path,testOrTrain,gtOrDet,preallocationSize)
            if nargin<4
                preallocationSize=0;
            end
            obj=obj@DataHandlers.DataStructure(path,testOrTrain,gtOrDet,preallocationSize);
            
            while(isempty(obj.myObjectFolder))
                tmpFolder=fullfile(tempdir,'Sun09tmp',char(randperm(6)+96));
                if ~exist(tmpFolder,'dir')
                    obj.myObjectFolder=tmpFolder;
                end
            end
        end
        function load(obj)
            filePath=fullfile(obj.path,[obj.storageName '.mat']);
            assert(exist(filePath,'file')>0,'DataStructure:fileNotFound',...
                'The file %s doesn''t exist.',filePath)
            loaded=load(filePath,[obj.setChooser{2}{1} obj.setChooser{1}]);
            tmpData=loaded.([obj.setChooser{2}{1} obj.setChooser{1}]);
            hasScore=isfield(tmpData(1).annotation.object,'confidence');
            hasOverlap=isfield(tmpData(1).annotation.object,'detection');
            for i=length(tmpData):-1:1
                for o=length(tmpData(i).annotation.object):-1:1
                    if hasScore
                        tmpScore=tmpData(i).annotation.object(o).confidence;
                    else
                        tmpScore=[];
                    end
                    if hasOverlap
                        tmpOverlap=double(tmpData(i).annotation.object(o).detection);
                    else
                        tmpOverlap=1;
                    end
                    tmpObject(o)=DataHandlers.ObjectStructure(tmpData(i).annotation.object(o).name,...
                        tmpScore,tmpOverlap,tmpData(i).annotation.object(o).polygon.x,...
                        tmpData(i).annotation.object(o).polygon.y);
                end
                obj.addImage(i,tmpData(i).annotation.filename,'',tmpData(i).annotation.folder,...
                    tmpData(i).annotation.imagesize,tmpObject,[]);
            end
        end
        function save(obj)
            filePath=fullfile(obj.path,[obj.storageName '.mat']);
            if ~exist(obj.path,'dir')
                [~,~,~]=mkdir(obj.path);
            end
            
            for i=length(obj.data):-1:1
                tmpStruct(1,i).annotation.filename=obj.getFilename(i);
                tmpStruct(1,i).annotation.folder=obj.getFolder(i);
                tmpStruct(1,i).annotation.imagesize=obj.getImagesize(i);
                tmpObjects=obj.getObject(i);
                for o=length(tmpObjects):-1:1
                    tmpStruct(1,i).annotation.object(o).name=tmpObjects(o).name;
                    tmpStruct(1,i).annotation.object(o).confidence=tmpObjects(o).score;
                    tmpStruct(1,i).annotation.object(o).detection=tmpObjects(o).overlap>=0.5;
                    tmpStruct(1,i).annotation.object(o).polygon=tmpObjects(o).polygon;
                end
            end
            
            tmpData.([obj.setChooser{2}{1} obj.setChooser{1}])=tmpStruct;
            if ~exist(filePath,'file')
                save(filePath,'-struct','tmpData');
            else
                save(filePath,'-struct','tmpData','-append');
            end
        end
        
        function delete(obj)
            [~,~,~]=rmdir(obj.myObjectFolder,'s');
        end
    end
    
    %% Protected Methods
    methods(Access='protected')        
        function name=getStorageName(obj)
            name=obj.setChooser{2}{2};
        end
        
        function name=getObjectSubfolderName(obj)
            name=[obj.setChooser{2}{1} obj.setChooser{1}];
        end
        
        function out=getPathToObjects(obj)
            out=obj.myObjectFolder;
        end
    end
end