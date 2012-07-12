classdef NYUDataStructure<DataHandlers.DataStructure
    %NYUDATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant)
        imageFolder='image'
        catFileName='objectCategories.mat'
        trainSet='Train'
        testSet='Test'
        gt='groundTruth'
        det='detections'
    end
    
    methods
        function obj=NYUDataStructure(path,testOrTrain,gtOrDet,preallocationSize)
            if nargin<4
                preallocationSize=0;
            end
            obj=obj@DataHandlers.DataStructure(path,testOrTrain,gtOrDet,preallocationSize);
        end
        function load(obj)
            filePath=fullfile(obj.path,[obj.storageName '.mat']);
            assert(exist(filePath,'file')>0,'DataStructure:fileNotFound',...
                'The file %s doesn''t exist.',filePath)
            loaded=load(filePath);
            obj.data=loaded.data;
        end
        function save(obj)
            filePath=fullfile(obj.path,[obj.storageName '.mat']);
            if ~exist(obj.path,'dir')
                [~,~,~]=mkdir(obj.path);
            end
            tmpObj.data=obj.data;
            save(filePath,'-struct','tmpObj');
        end
    end
    
    %% Protected Methods for File Conversion
    methods(Access='protected')
        function name=getStorageName(obj)
            if strcmpi(obj.setChooser{2},'gt')
                name=obj.gt;
            else
                name=obj.det;
            end
            
            if strcmpi(obj.setChooser{1},'train')
                name=[name obj.trainSet];
            else
                name=[name obj.testSet];
            end
        end
        
        function name=getObjectSubfolderName(obj)
            name=obj.getStorageName();
        end
        
        function out=getPathToObjects(obj)
            out=obj.path;
        end
    end
end