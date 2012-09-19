classdef NYUDataStructure<DataHandlers.DataStructure
    %NYUDATASTRUCTURE Implementation of DATAHANDLERS.DATASTRUCTURE
    %   This class implements the abstract class DATAHANDLERS.DATASTRUCTURE
    %   for data generated with DATAHANDLERS.CONVERTFROMNYUDATASET.
    properties(Constant)
        imageFolder='image'
        catFileName='objectCategories.mat'
        testSet='groundTruthTest'
        trainSet='groundTruthTrain'
    end
    
    methods
        function obj=NYUDataStructure(path,testOrTrain)
            %OBJ=NYUDATASTRUCTURE(PATH,TESTORTRAIN)
            %   See also DATAHANDLERS.DATASTRUCTURE.DATASTRUCTURE
            
            obj=obj@DataHandlers.DataStructure(path,testOrTrain);
        end
        function load(obj)
            %LOAD(OBJ) Loads the dataset from disk
            filePath=fullfile(obj.path,[obj.storageName '.mat']);
            assert(exist(filePath,'file')>0,'DataStructure:fileNotFound',...
                'The file %s doesn''t exist.',filePath)
            loaded=load(filePath);
            obj.data=loaded.data;
        end
        function save(obj)
            %SAVE(OBJ) Saves the dataset to disk
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
            if strcmpi(obj.setChooser,'train')
                name=obj.trainSet;
            else
                name=obj.testSet;
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