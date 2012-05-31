classdef GroundTruthLoader<ImageLoader
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
%     properties(SetAccess='private')
%         nrImgs
%         cIndex
%         fileList
%         path
%     end
    properties(Constant,GetAccess='private')
%         imgTag='img_';
%         imgPathTag=['image' filesep];
%         imgExt='.jpg';
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
%         its=length(ImageLoader.imgTag)+1;
    end
    
    %% Public Methods
    methods
        function obj=GroundTruthLoader(filePath)
            obj.path=ImageLoader.checkPath(filePath);
            obj.fileList=obj.getFileNameList();
            obj.nrImgs=length(obj.fileList);
            obj.cIndex=1;
        end
        
        function clean(obj)
            [~,~,~]=rmdir([obj.path obj.combPathTag],'s');
        end
    end
    
    %% Private Methods
    methods(Access='protected')
        function image=loadImage(obj,name)
            combPath=[obj.path obj.combPathTag obj.combTag name obj.combExt];

            goodMat=false;

            if exist(combPath,'file')
                image=load(combPath);
                goodMat=isfield(image,'calib') && isfield(image,'depth') &&...
                    isfield(image,'img') && isfield(image,'objects') &&...
                    isfield(image,'imgsize');
            end

            if ~goodMat
                if obj.checkCompleteness(name)
                    [annoPath,calibPath,~,depthPath]=obj.generatePaths(name);
                    image.calib=dlmread(calibPath);
                    image.depth=dlmread(depthPath);
                    image.img=[obj.imgPathTag obj.imgTag name obj.imgExt];
                    image.objects=searchObjects(annoPath);
                    tmpImage=imread([obj.path image.img]);
                    tmpSize=size(tmpImage);
                    image.imgsize=tmpSize([2 1 3]);
                    
                    image.objects=obj.evaluateDepth(image.objects,image.depth,...
                        image.calib,image.imgsize);

                    if ~exist([obj.path obj.combPathTag],'dir')
                        [~,~,~]=mkdir([obj.path obj.combPathTag]);
                    end
                    
                    save(combPath,'-struct','image');
                end
            end
        end

        function valid=checkCompleteness(obj,name)
            [annoPath,calibPath,colorPath,depthPath]=obj.generatePaths(name);
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

        function [annoP,calibP,colorP,depthP]=generatePaths(obj,name)
            calibP=[obj.path obj.calibPathTag obj.calibTag name obj.calibExt];
            depthP=[obj.path obj.depthPathTag obj.depthTag name obj.depthExt];
            colorP=[obj.path obj.imgPathTag obj.imgTag name obj.imgExt];
            annoP=[obj.path obj.annoPathTag obj.annoTag name obj.annoExt];
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

% function objects=evaluateDepth(objects,depth,calib,imgsize)
%     %disp('Implement depth evaluation damn it!')
% 
%     for o=1:length(objects)
%         mask=poly2mask([objects(o).polygon.pt(:).x],...
%             [objects(o).polygon.pt(:).y],imgsize(2),imgsize(1));
%         medDepth=median(depth(mask==1 & isnan(depth)==0));
%         bbPoints=zeros(3,2);
%         bbPoints(:,1)=[min([objects(o).polygon.pt.x]);min([objects(o).polygon.pt.y]);1];
%         bbPoints(:,2)=[max([objects(o).polygon.pt.x]);max([objects(o).polygon.pt.y]);1];
%         normBBPoints=calib\bbPoints;
%         normBBPoints=normBBPoints*medDepth;
%         objects(o).pos=mean(normBBPoints,2);
%         objects(o).dim=[normBBPoints(1,2)-normBBPoints(1,1) normBBPoints(2,2)-normBBPoints(2,1)];
%     end
% end
