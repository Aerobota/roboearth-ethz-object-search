classdef DataLoader<handle
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(SetAccess='protected')
        classes
        path
%         trainSet
%         testSet
    end
    properties(Abstract,Constant)
        trainSet
        testSet
    end
%     properties(Constant,GetAccess='protected')
%         imgPath=DataHandlers.CompoundPath('img_','image','.jpg');
%         its=length(DataHandlers.DataLoader.imgPath.tag)+1;
%     end
    
    %% Public Methods
    methods
        function obj=DataLoader(filePath)
            obj.path=DataHandlers.checkPath(filePath);
%             obj.classes=classes;
%             obj.fileList=obj.getFileNameList();
%             obj.nrImgs=length(obj.fileList);
%             obj.cIndex=1;
        end
    end
    methods(Abstract)
        image=getData(obj,desiredSet);
    end
    
    %% Protected Methods
%     methods(Abstract,Access='protected')
%         image=loadData(obj,name);
%     end
%     methods(Access='protected')
%         function fileNameList=getFileNameList(obj)
%             dirList=dir(obj.imgPath.getPath('*',obj.path));
%             fileNameList=cell(length(dirList),1);
%             for i=1:length(dirList)
%                 [~,imgName,~]=fileparts(dirList(i).name);
%                 fileNameList{i}=imgName(obj.its:end);
%             end
%         end
%     end
    
%     methods(Static,Access='protected')
%         
%     end
end

