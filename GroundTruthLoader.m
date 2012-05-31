classdef GroundTruthLoader<ImageLoader
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(Constant,GetAccess='private')
        combPath=CompoundPath('combImage_','combined','.mat');
        depthPath=CompoundPath('depth_','depth','.txt');
        calibPath=CompoundPath('calib_','calibration','.txt');
        annoPath=CompoundPath('anno_','annotation','.xml');
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
            [~,~,~]=rmdir([obj.path obj.combPath.path],'s');
        end
    end
    
    %% Private Methods
    methods(Access='protected')
        function image=loadImage(obj,name)
            longCombPath=obj.combPath.getPath(name,obj.path);

            goodMat=false;

            if exist(longCombPath,'file')
                image=load(longCombPath);
                goodMat=isfield(image,'calib') && isfield(image,'depth') &&...
                    isfield(image,'img') && isfield(image,'objects') &&...
                    isfield(image,'imgsize');
            end

            if ~goodMat
                if obj.checkCompleteness(name)
                    image.calib=dlmread(obj.calibPath.getPath(name,obj.path));
                    image.depth=dlmread(obj.depthPath.getPath(name,obj.path));
                    image.img=obj.imgPath.getPath(name);
                    image.objects=searchObjects(obj.annoPath.getPath(name,obj.path));
                    tmpImage=imread([obj.path image.img]);
                    tmpSize=size(tmpImage);
                    assert(all(tmpSize(1:2)==size(image.depth)),'RGB and Depth image have different sizes');
                    image.imgsize=tmpSize([2 1 3]);
                    
                    image.objects=obj.evaluateDepth(image.objects,image.depth,...
                        image.calib,image.imgsize);

                    if ~exist([obj.path obj.combPath.path],'dir')
                        [~,~,~]=mkdir([obj.path obj.combPath.path]);
                    end
                    
                    save(longCombPath,'-struct','image');
                end
            end
        end

        function valid=checkCompleteness(obj,name)
            valid=exist(obj.calibPath.getPath(name,obj.path),'file') &&...
                exist(obj.imgPath.getPath(name,obj.path),'file') &&...
                exist(obj.depthPath.getPath(name,obj.path),'file');
            
            if ~exist(obj.annoPath.getPath(name,obj.path),'file')
                [tmpPath,~,~]=fileparts(obj.annoPath.getPath(name,obj.path));
                [~,tmpName,~]=fileparts(obj.imgPath.getPath(name,obj.path));
                tmpAnno=[tmpPath filesep obj.imgPath.path tmpName obj.annoPath.ext];
                if exist(tmpAnno,'file')
                    movefile(tmpAnno,obj.annoPath.getPath(name,obj.path));
                end

                if length(dir([tmpPath filesep obj.imgPath.path '*']))<=2
                    [~,~,~]=rmdir([tmpPath filesep obj.imgPath.path]);
                end
            end
            valid=valid && exist(obj.annoPath.getPath(name,obj.path),'file');
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