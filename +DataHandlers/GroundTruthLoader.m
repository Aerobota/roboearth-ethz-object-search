classdef GroundTruthLoader<DataHandlers.DistributedDataLoader
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(Constant,GetAccess='protected')
        combPath=DataHandlers.CompoundPath('combImage_','combined','.mat');
        depthPath=DataHandlers.CompoundPath('depth_','depth','.txt');
        calibPath=DataHandlers.CompoundPath('calib_','calibration','.txt');
        annoPath=DataHandlers.CompoundPath('anno_','annotation','.xml');
    end
    
    %% Public Methods
    methods
        function obj=GroundTruthLoader(filePath,forceUpdate)
            if nargin<2
                forceUpdate=false;
            end
            
            obj=obj@DataHandlers.DistributedDataLoader(filePath,forceUpdate);
        end
        
        function clean(obj)
            [~,~,~]=rmdir(fullfile(obj.path,obj.combPath.path),'s');
        end
    end
    
    %% Private Methods
    methods(Access='protected')
        function image=loadData(obj,name)
            longCombPath=obj.combPath.getPath(name,obj.path);

            goodMat=false;

            if exist(longCombPath,'file')
                image=load(longCombPath);
                goodMat=isfield(image,'annotation');
                if goodMat
                    goodMat=isfield(image.annotation,'calib') &&...
                        isfield(image.annotation,'depth') &&...
                        isfield(image.annotation,'img') &&...
                        isfield(image.annotation,'object') &&...
                        isfield(image.annotation,'filename') &&...
                        isfield(image.annotation,'folder') &&...
                        isfield(image.annotation,'imagesize');
                end
            end

            if ~goodMat
                obj.checkCompleteness(name)
                image.annotation=obj.generateImage(name);

                if ~exist(fullfile(obj.path,obj.combPath.path),'dir')
                    [~,~,~]=mkdir(fullfile(obj.path,obj.combPath.path));
                end

                save(longCombPath,'-struct','image');
            end
        end

        function checkCompleteness(obj,name)
            obj.relocateAnnotationFile(name);
            calibV=exist(obj.calibPath.getPath(name,obj.path),'file');
            imgV=exist(obj.imgPath.getPath(name,obj.path),'file');
            depthV=exist(obj.depthPath.getPath(name,obj.path),'file');
            annoV=exist(obj.annoPath.getPath(name,obj.path),'file');
            if(~(annoV && calibV && depthV && imgV))
                missingFiles=[];
                if(~annoV)
                    missingFiles=[missingFiles sprintf('\t%s\n',obj.annoPath.getPath(name))];
                end
                if(~calibV)
                    missingFiles=[missingFiles sprintf('\t%s\n',obj.calibPath.getPath(name))];
                end
                if(~depthV)
                    missingFiles=[missingFiles sprintf('\t%s\n',obj.depthPath.getPath(name))];
                end
                error('checkCompleteness:dataMissing',...
                    'Following files are missing for image \"%s\":\n%s',...
                    obj.imgPath.getPath(name),missingFiles);
            end
        end
        
        function imageData=generateImage(obj,name)
            imageData.calib=dlmread(obj.calibPath.getPath(name,obj.path));
            imageData.depth=dlmread(obj.depthPath.getPath(name,obj.path));
            imageData.img=obj.imgPath.getPath(name);
            imageData.filename=obj.imgPath.getFileName(name);
            imageData.folder='';
            imageData.object=searchObjects(obj.annoPath.getPath(name,obj.path));
            tmpRGB=imread(fullfile(obj.path,imageData.img));
            tmpSize=size(tmpRGB);
            assert(all(tmpSize(1:2)==size(imageData.depth)),'RGB and Depth image have different sizes');
            imageData.imagesize.nrows=tmpSize(1);
            imageData.imagesize.ncols=tmpSize(2);

            imageData.object=DataHandlers.evaluateDepth(imageData.object,imageData.depth,...
                imageData.calib,imageData.imagesize);
        end
        
        function relocateAnnotationFile(obj,name)
            if ~exist(obj.annoPath.getPath(name,obj.path),'file')
                [tmpPath,~,~]=fileparts(obj.annoPath.getPath(name,obj.path));
                [~,tmpName,~]=fileparts(obj.imgPath.getPath(name,obj.path));
                tmpAnno=[tmpPath filesep obj.imgPath.path tmpName obj.annoPath.ext];
                if exist(tmpAnno,'file')
                    movefile(tmpAnno,obj.annoPath.getPath(name,obj.path));
                end

                if length(dir(fullfile(tmpPath,obj.imgPath.path,'*')))<=2
                    [~,~,~]=rmdir(fullfile(tmpPath,obj.imgPath.path));
                end
            end
        end
    end
end

%% Support Functions
function objects=searchObjects(filename)
    doc=xmlread(filename);

    objects=searchRecursion(doc);
    
    for o=1:length(objects)
        for n=length(objects(o).polygon.pt):-1:1
            objects(o).polygon.x(n,1)=objects(o).polygon.pt(n).x;
            objects(o).polygon.y(n,1)=objects(o).polygon.pt(n).y;
        end
    end
end

function objects=searchRecursion(node)
    children=node.getChildNodes;
    nrC=children.getLength;
    objects=[];
    for i=0:nrC-1
        if strcmp(char(children.item(i).getNodeName),'object')==1
            objects=[objects parseRecursion(children.item(i))];
        else
            objects=[objects searchRecursion(children.item(i))];
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
                part.(name)=[part.(name) parseRecursion(children.item(i))];
            else
                part.(name)=parseRecursion(children.item(i)); 
            end
        end
    end
end