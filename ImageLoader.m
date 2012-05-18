classdef ImageLoader<handle
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(Access='private')
        fileList
        path
    end
    properties(SetAccess='private')
        nrImgs
        cIndex
    end
    properties(Constant,Access='private')
        imgTag='img_';
        imgPathTag=['image' filesep];
        imgExt='.jpg';
        combTag='combImage_';
        combPathTag=['combined' filesep];
        combExt='.mat';
        depthTag='depth_';
        depthPathTag=['depth' filesep];
        depthExt='.txt';
        calibTag='calib_';
        calibPathTag=['calibration' filesep];
        calibExt='.txt';
        annoTag='anno_';
        annoPathTag=['annotation' filesep];
        annoExt='.xml';
        its=length(ImageLoader.imgTag)+1;
    end
    
    %% Public Methods
    methods
        function obj=ImageLoader(filePath)
            if filePath(end)~=filesep
                filePath=[filePath filesep];
            end
            obj.path=filePath;
            imgPath=[obj.path obj.imgPathTag];
            dirList=dir([imgPath ImageLoader.imgTag '*']);
            tmpInd=1;
            for i=1:length(dirList)
                [~,imgName,~]=fileparts(dirList(i).name);
                if(obj.checkCompleteness(obj.path,imgName(ImageLoader.its:end)))
                    obj.fileList{tmpInd}=imgName(ImageLoader.its:end);
                    tmpInd=tmpInd+1;
                end
            end
            obj.nrImgs=length(obj.fileList);
            obj.cIndex=1;
        end
        
        function image=getImage(obj,index)
            if nargin==1
                index=obj.cIndex;
                obj.cIndex=obj.cIndex+1;
                if index>obj.nrImgs
                    image=0;
                    return
                end
            end
            image=obj.loadImage(obj.path,obj.fileList{index});
        end
        
        function resetIterator(obj)
            obj.cIndex=1;
        end
        
        function generateCollection(obj)
            parfor index=1:length(obj.fileList)
                obj.loadImage(obj.path,obj.fileList{index});
            end
        end
    end
    
    %% Private Methods
    methods(Access='private')
        function image=loadImage(obj,path,name)
            combPath=[path obj.combPathTag obj.combTag name obj.combExt];

            goodMat=false;

            if exist(combPath,'file')
                image=load(combPath);
                goodMat=isfield(image,'calib') && isfield(image,'depth') &&...
                    isfield(image,'img') && isfield(image,'objects');
            end

            if ~goodMat
                if obj.checkCompleteness(path,name)
                    [annoPath,calibPath,colorPath,depthPath]=obj.generatePaths(path,name);
                    
                    image.calib=dlmread(calibPath);
                    image.depth=dlmread(depthPath);
                    image.img=[obj.imgPathTag obj.imgTag name obj.imgExt];
                    image.objects=searchObjects(annoPath);

                    calib=image.calib;
                    depth=image.depth;
                    img=image.img;
                    objects=image.objects;

                    if ~exist([path obj.combPathTag],'dir')
                        [~,~,~]=mkdir([path obj.combPathTag]);
                    end
                    save(combPath,'calib','depth','img','objects');
                end
            end
            
            image.img=[path image.img];
        end

        function valid=checkCompleteness(obj,path,name)
            [annoPath,calibPath,colorPath,depthPath]=obj.generatePaths(path,name);
            valid=exist(calibPath,'file') && exist(colorPath,'file') && exist(depthPath,'file');

            if ~exist(annoPath,'file')
                [tmpPath,~,~]=fileparts(annoPath);
                [~,tmpName,~]=fileparts(colorPath);
                tmpAnno=[tmpPath filesep obj.imgPathTag tmpName obj.annoExt];
                if exist(tmpAnno,'file')
                    movefile(tmpAnno,annoPath);
                end

                if length(dir([tmpPath filesep obj.imgPathTag '*']))<=2
                    [~,~,~]=rmdir([tmpPath filesep obj.imgPathTag]);
                end
            end
            valid=valid && exist(annoPath,'file');
        end

        function [annoP,calibP,colorP,depthP]=generatePaths(obj,path,name)
            calibP=[path obj.calibPathTag obj.calibTag name obj.calibExt];
            depthP=[path obj.depthPathTag obj.depthTag name obj.depthExt];
            colorP=[path obj.imgPathTag obj.imgTag name obj.imgExt];
            annoP=[path obj.annoPathTag obj.annoTag name obj.annoExt];
        end
    end
    
end


%% Support Functions
function objects=searchObjects(filename)
    doc=xmlread(filename);
    
    objects=searchRecursion(doc);
end


function objects=searchRecursion(node)
    children=node.getChildNodes;
    nrC=children.getLength;
    objects=[];
    for i=0:nrC-1
        if strcmp(char(children.item(i).getNodeName),'object')==1
            objects=[objects;parseRecursion(children.item(i))];
        else
            objects=[objects;searchRecursion(children.item(i))];
        end
    end
end

function part=parseRecursion(node)
    children=node.getChildNodes;
    nrC=children.getLength;
    if nrC==1
        if ~isempty(char(children.item(0).getNodeValue))
            part=char(children.item(0).getNodeValue);
            part=part(2:end-1);
            if ~isnan(str2double(part))
                part=str2double(part);
            end
            return
        end
    end
    
    part=[];
    
    for i=0:nrC-1
        name=char(children.item(i).getNodeName);
        if name(1)~='#'
            if isfield(part,name)
                part.(name)=[part.(name);parseRecursion(children.item(i))];
            else
                part.(name)=parseRecursion(children.item(i)); 
            end
        end
    end
end