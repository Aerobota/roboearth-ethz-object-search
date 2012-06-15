classdef DistributedDataLoader<DataHandlers.DataLoader
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(SetAccess='protected')
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
        trainSet={'trainval.txt'}
        testSet={'test.txt'}
        classFile={'classes.mat'} %maybe don't read from file but get passed in ctr
    end
    
    %% Public Methods
    methods
        function obj=DistributedDataLoader(filePath)
            &&&&&& % call super-class constructor and read class list file
            &&&&&& % also parse filelist file for faster access (or do on first use)
%             obj.path=DataHandlers.checkPath(filePath);
%             obj.fileList=obj.getFileNameList();
%             obj.nrImgs=length(obj.fileList);
%             obj.cIndex=1;
        end
        
        function images=getData(obj,dataSet)
            &&&&&& % load complete dataSet via single file loader
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
            &&&&&& % load fileList file (and parse if necessary) and 
            &&&&&& % call loadImage for the corresponding file
        end
        
%         function resetIterator(obj)
%             obj.cIndex=1;
%         end
        
        function generateNameList(obj,listName)
            &&&&&& % this should be adapted for automatic splitting of data
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
    end
    methods(Abstract)
        clean(obj);
    end
    
    %% Protected Methods
    methods(Abstract,Access='protected')
        image=loadData(obj,name);
    end
    methods(Access='protected')
        function fileNameList=getFileNameList(obj)
            &&&&&& % three lists with names for 'all','training' and 'test'
            &&&&&& % make it possible to force update
%             dirList=dir(obj.imgPath.getPath('*',obj.path));
%             fileNameList=cell(length(dirList),1);
%             for i=1:length(dirList)
%                 [~,imgName,~]=fileparts(dirList(i).name);
%                 fileNameList{i}=imgName(obj.its:end);
%             end
        end
        
    end
    
    methods(Static,Access='protected')
        function classes=getClasses(obj)
            &&&&&& % generate or read a matfile with the classes and return them
        end
    end
end