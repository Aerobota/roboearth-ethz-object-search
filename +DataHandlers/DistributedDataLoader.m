classdef DistributedDataLoader<DataHandlers.DataLoader
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(SetAccess='protected')
        files
        badIndex
%         nrImgs
%         cIndex
%         fileList
%         path
    end
    properties(Constant,GetAccess='protected')
        imgPath=DataHandlers.CompoundPath('img_','image','.jpg');
        its=length(DataHandlers.DistributedDataLoader.imgPath.tag)+1;
    end
    properties(Constant)
        trainSet='trainval'
        testSet='test'
        classFile='classes.mat' %maybe don't read from file but get passed in ctr
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
            
            
%             &&&&&& % call super-class constructor and read class list file
%             &&&&&& % also parse filelist file for faster access (or do on first use)
%             obj.path=DataHandlers.checkPath(filePath);
%             obj.fileList=obj.getFileNameList();
%             obj.nrImgs=length(obj.fileList);
%             obj.cIndex=1;
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
%             &&&&&& % load complete dataSet via single file loader
%             if nargin==1
%                 index=obj.cIndex;
%                 gotData=false;
%                 while (~gotData && index<=obj.nrImgs)
%                     try
%                         image=obj.loadData(obj.fileList{index});
%                         gotData=true;
%                     catch error
%                         if(strcmp(error.identifier,'checkCompleteness:dataMissing')==0)
%                             rethrow(error);
%                         end
%                     end
%                     index=index+1;
%                     obj.cIndex=index;
%                 end
%                 assert(gotData,'getData:noImages','No more images were found');
%             elseif isnumeric(index)
%                 image=obj.loadData(obj.fileList{index});
%             else
%                 image=obj.loadData(index);
%             end
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
%             &&&&&& % load fileList file (and parse if necessary) and 
%             &&&&&& % call loadImage for the corresponding file
        end
        
        function image=getDataByName(obj,name)
            image=obj.loadData(name);
%             &&&&&& % load fileList file (and parse if necessary) and 
%             &&&&&& % call loadImage for the corresponding file
        end
        
%         function resetIterator(obj)
%             obj.cIndex=1;
%         end
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
%             &&&&&& % three lists with names for 'all','training' and 'test'
%             &&&&&& % make it possible to force update
%             dirList=dir(obj.imgPath.getPath('*',obj.path));
%             fileNameList=cell(length(dirList),1);
%             for i=1:length(dirList)
%                 [~,imgName,~]=fileparts(dirList(i).name);
%                 fileNameList{i}=imgName(obj.its:end);
%             end
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
            
            split
            
            obj.files.(obj.trainSet)=fileNameList(split);
            obj.files.(obj.testSet)=fileNameList(~split);
            
            obj.writeFileNameListFile(fullfile(obj.path,[obj.trainSet '.txt']),obj.files.(obj.trainSet));
            obj.writeFileNameListFile(fullfile(obj.path,[obj.testSet '.txt']),obj.files.(obj.testSet));
%             &&&&&& % this should be adapted for automatic splitting of data
%             if iscell(listName)==0
%                 listName={listName};
%             end
%             for l=1:length(listName)
%                 fid=fopen([obj.path listName{l}],'wt');
%                 for i=1:obj.nrImgs
%                     fprintf(fid,'%s\n',obj.fileList{i}); 
%                 end
%                 fclose(fid);
%             end
        end
%         function classes=getClasses(obj,forceUpdate)
%             tmpPath=fullfile(obj.path,obj.classFile);
%             if exist(tmpPath,'file') && ~forceUpdate
%                 classes=load(tmpPath);
%             else
%                 trainClasses=obj.getClassesFromData(obj.trainSet);
%                 testClasses=obj.getClassesFromData(obj.testSet);
%                 inBoth=ismember(trainClasses,testClasses);
%                 classes=
%             end
%             %&&&&&& % generate or read a matfile with the classes and return them
%         end
        function cleanFileNameListFile(obj,dataSet)
            tmpPath=fullfile(obj.path,[dataSet '.txt']);
            oldNames=obj.parseFileNameListFile(tmpPath);
            badNames=ismember(oldNames,obj.files.(dataSet)(obj.badIndex.(dataSet),1));
            if any(badNames)
                obj.writeFileNameListFile(tmpPath,oldNames(~badNames,1));
            end
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