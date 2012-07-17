classdef SunDataStructure<DataHandlers.DataStructure
    %SUNDATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access='protected')
        myObjectFolder
    end
    
    properties(Constant)
        imageFolder='Images'
        catFileName='sun09_objectCategories.mat'
        testSet='Dtest'
        trainSet='Dtraining'
        storageFile='sun09_groundTruth'
    end
    
    methods
        function obj=SunDataStructure(path,testOrTrain,preallocationSize)
            if nargin<3
                preallocationSize=0;
            end
            obj=obj@DataHandlers.DataStructure(path,testOrTrain,preallocationSize);
            
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
            loaded=load(filePath,obj.getObjectSubfolderName());
            tmpData=loaded.(obj.getObjectSubfolderName());
            for i=length(tmpData):-1:1
                tmpObject=DataHandlers.ObjectStructure.empty();
                for o=length(tmpData(i).annotation.object):-1:1
                    tmpObject(o)=DataHandlers.ObjectStructure(tmpData(i).annotation.object(o).name,...
                        double(tmpData(i).annotation.object(o).polygon.x),...
                        double(tmpData(i).annotation.object(o).polygon.y));
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
                    tmpStruct(1,i).annotation.object(o).polygon=tmpObjects(o).polygon;
                end
            end
            
            tmpData.(obj.getObjectSubfolderName())=tmpStruct;
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
            name=obj.storageFile;
        end
        
        function name=getObjectSubfolderName(obj)
            if strcmpi(obj.setChooser,'train')
                name=obj.trainSet;
            else
                name=obj.testSet;
            end
        end
        
        function out=getPathToObjects(obj)
            out=obj.myObjectFolder;
        end
    end
end