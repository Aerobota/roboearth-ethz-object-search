classdef DataLoader<handle
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(SetAccess='protected')
        nrImgs
        cIndex
        fileList
        path
    end
    properties(Constant,GetAccess='protected')
        imgPath=DataHandlers.CompoundPath('img_','image','.jpg');
        its=length(DataHandlers.DataLoader.imgPath.tag)+1;
    end
    
    %% Public Methods
    methods
        function obj=DataLoader(filePath)
            obj.path=obj.checkPath(filePath);
            obj.fileList=obj.getFileNameList();
            obj.nrImgs=length(obj.fileList);
            obj.cIndex=1;
        end
        
        function image=getData(obj,index)
            if nargin==1
                index=obj.cIndex;
                gotData=false;
                while (~gotData && index<=obj.nrImgs)
                    try
                        image=obj.loadData(obj.fileList{index});
                        gotData=true;
                    catch error
                        if(strcmp(error.identifier,'checkCompleteness:dataMissing')==0)
                            rethrow(error);
                        end
                    end
                    index=index+1;
                    obj.cIndex=index;
                end
                assert(gotData,'getData:noImages','No more images were found');
            elseif isnumeric(index)
                image=obj.loadData(obj.fileList{index});
            else
                image=obj.loadData(index);
            end
        end
        
        function resetIterator(obj)
            obj.cIndex=1;
        end
        
        function generateNameList(obj,listName)
            if iscell(listName)==0
                listName={listName};
            end
            for l=1:length(listName)
                fid=fopen([obj.path listName{l}],'wt');
                for i=1:obj.nrImgs
                    fprintf(fid,'%s\n',obj.fileList{i}); 
                end
                fclose(fid);
            end
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
            dirList=dir(obj.imgPath.getPath('*',obj.path));
            fileNameList=cell(length(dirList),1);
            for i=1:length(dirList)
                [~,imgName,~]=fileparts(dirList(i).name);
                fileNameList{i}=imgName(obj.its:end);
            end
        end
    end
    
    methods(Static,Access='protected')
        function clean=checkPath(dirty)
            if dirty(end)~=filesep
                clean=[dirty filesep];
            else
                clean=dirty;
            end
            if exist(clean,'dir')==0
                error('The specified directory was not found');
            end
        end
    end
end