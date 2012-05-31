classdef ImageLoader<handle
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
        imgPath=CompoundPath('img_','image','.jpg');
        its=length(ImageLoader.imgPath.tag)+1;
    end
    
    %% Public Methods
    methods
        function image=getImage(obj,index)
            if nargin==1
                index=obj.cIndex;
                obj.cIndex=obj.cIndex+1;
                if index>obj.nrImgs
                    image=0;
                    return
                end
            end
            if isnumeric(index)
                image=obj.loadImage(obj.fileList{index});
            else
                image=obj.loadImage(index);
            end
        end
        
        function resetIterator(obj)
            obj.cIndex=1;
        end
        
        function generateCollection(obj)
            parfor index=1:length(obj.fileList)
                obj.loadImage(obj.fileList{index});
            end
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
        image=loadImage(obj,name);
        valid=checkCompleteness(obj,name);
    end
    methods(Access='protected')
        function fileNameList=getFileNameList(obj)
            dirList=dir(obj.imgPath.getPath('*',obj.path));
            tmpInd=1;
            for i=1:length(dirList)
                [~,imgName,~]=fileparts(dirList(i).name);
                if(obj.checkCompleteness(imgName(obj.its:end)))
                    fileNameList{tmpInd}=imgName(obj.its:end);
                    tmpInd=tmpInd+1;
                end
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
        
        function objects=evaluateDepth(objects,depth,calib,imgsize)
            for o=1:length(objects)
                mask=poly2mask([objects(o).polygon.pt(:).x],...
                    [objects(o).polygon.pt(:).y],imgsize(2),imgsize(1));
                medDepth=median(depth(mask==1 & isnan(depth)==0));
                bbPoints=zeros(3,2);
                bbPoints(:,1)=[min([objects(o).polygon.pt.x]);min([objects(o).polygon.pt.y]);1];
                bbPoints(:,2)=[max([objects(o).polygon.pt.x]);max([objects(o).polygon.pt.y]);1];
                normBBPoints=calib\bbPoints;
                normBBPoints=normBBPoints*medDepth;
                objects(o).pos=mean(normBBPoints,2);
                objects(o).dim=[normBBPoints(1,2)-normBBPoints(1,1) normBBPoints(2,2)-normBBPoints(2,1)];
            end
        end
    end
end