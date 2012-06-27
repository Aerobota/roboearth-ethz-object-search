classdef DistributedDataLoader<DataHandlers.DataLoader
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(SetAccess='protected')
        files
        badIndex
    end
    properties(Constant,GetAccess='protected')
        imgPath=DataHandlers.CompoundPath('img_','image','.jpg');
        its=length(DataHandlers.DistributedDataLoader.imgPath.tag)+1;
    end
    properties(Constant)
        trainSet='train'
        testSet='test'
        classFile='classes.mat'
        imageFolder='image'
    end
    
    %% Public Methods
    methods
        function obj=DistributedDataLoader(filePath,forceUpdate)
            obj=obj@DataHandlers.DataLoader(filePath);
            
            obj.classes=load(fullfile(obj.path,obj.classFile));
            
            if forceUpdate
                obj.generateFileNameLists();
            else
                obj.evaluateFileNameLists();
            end
            
            obj.badIndex.(obj.trainSet)=false(length(obj.files.(obj.trainSet)),1);
            obj.badIndex.(obj.testSet)=false(length(obj.files.(obj.testSet)),1);
        end
        
        function images=getData(obj,dataSet)
            indicesGood=true(1,length(obj.files.(dataSet)));
            for i=length(obj.files.(dataSet)):-1:1
                try
                    images(1,i)=obj.getSingleData(dataSet,i);
                catch error
                    if(strcmp(error.identifier,'checkCompleteness:dataMissing')==1)
                        indicesGood(1,i)=false;
                    else
                        rethrow(error);
                    end
                end
            end
            images=images(1,indicesGood);
        end
        
        function image=getSingleData(obj,dataSet,index)
            try
                image=obj.loadData(obj.files.(dataSet){index});
            catch error
                if(strcmp(error.identifier,'checkCompleteness:dataMissing')==1)
                    obj.badIndex.(dataSet)(index,1)=true;
                end
                
                rethrow(error);
            end
        end
        
        function image=getDataByName(obj,name)
            image=obj.loadData(name);
        end
        
        function delete(obj)
            obj.cleanFileNameListFile(obj.trainSet);
            obj.cleanFileNameListFile(obj.testSet);
        end
    end
    methods(Abstract)
        clean(obj);
    end
    
    %% Protected Methods
    methods(Abstract,Access='protected')
        image=loadData(obj,name);
    end
    methods(Access='protected')
        function evaluateFileNameLists(obj)
            pathTrain=fullfile(obj.path,[obj.trainSet '.txt']);
            pathTest=fullfile(obj.path,[obj.testSet '.txt']);
            if exist(pathTrain,'file') && exist(pathTest,'file')
                obj.files.(obj.trainSet)=obj.parseFileNameListFile(pathTrain);
                obj.files.(obj.testSet)=obj.parseFileNameListFile(pathTest);
            else
                obj.generateFileNameLists();
            end
        end
        function generateFileNameLists(obj)
            dirList=dir(obj.imgPath.getPath('*',obj.path));
            fileNameList=cell(length(dirList),1);
            for i=1:length(dirList)
                [~,imgName,~]=fileparts(dirList(i).name);
                fileNameList{i}=imgName(obj.its:end);
            end
            
            split=false(length(fileNameList),1);
            while abs(sum(split)-length(fileNameList)/2)>1
                split=rand(length(fileNameList),1)<0.5;
            end
            
            obj.files.(obj.trainSet)=fileNameList(split);
            obj.files.(obj.testSet)=fileNameList(~split);
            
            obj.writeFileNameListFile(fullfile(obj.path,[obj.trainSet '.txt']),obj.files.(obj.trainSet));
            obj.writeFileNameListFile(fullfile(obj.path,[obj.testSet '.txt']),obj.files.(obj.testSet));
        end
        
        function cleanFileNameListFile(obj,dataSet)
            tmpPath=fullfile(obj.path,[dataSet '.txt']);
            oldNames=obj.parseFileNameListFile(tmpPath);
            badNames=ismember(oldNames,obj.files.(dataSet)(obj.badIndex.(dataSet),1));
            if any(badNames)
                obj.writeFileNameListFile(tmpPath,oldNames(~badNames,1));
            end
        end
        
        function data=removeAliasesImpl(~,data,~)
            warning('removeAliasesImpl:notImplemented','Not implemented')
        end
    end
    
    methods(Static,Access='protected')
        function fileNames=parseFileNameListFile(path)
            fid=fopen(path,'rt');
            fileNames=cell(0,1);
            line=fgetl(fid);
            while length(line)~=1 && line(1)~=-1
                fileNames{end+1,1}=line;
                line=fgetl(fid);
            end
            fclose(fid);
        end
        
        function writeFileNameListFile(path,fileNames)
            fid=fopen(path,'wt');
            for i=1:length(fileNames)
                fprintf(fid,'%s\n',fileNames{i}); 
            end
            fclose(fid);
        end
    end
end