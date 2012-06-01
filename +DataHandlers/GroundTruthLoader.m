classdef GroundTruthLoader<DataHandlers.DataLoader
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
        function obj=GroundTruthLoader(filePath)
            obj=obj@DataHandlers.DataLoader(filePath);
        end
        
        function clean(obj)
            [~,~,~]=rmdir([obj.path obj.combPath.path],'s');
        end
    end
    
    %% Private Methods
    methods(Access='protected')
        function image=loadData(obj,name)
            longCombPath=obj.combPath.getPath(name,obj.path);

            goodMat=false;

            if exist(longCombPath,'file')
                image=load(longCombPath);
                goodMat=isfield(image,'calib') && isfield(image,'depth') &&...
                    isfield(image,'img') && isfield(image,'objects') &&...
                    isfield(image,'imgsize');
            end

            if ~goodMat
                obj.checkCompleteness(name)
                image=obj.generateImage(name);

                if ~exist([obj.path obj.combPath.path],'dir')
                    [~,~,~]=mkdir([obj.path obj.combPath.path]);
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
        
        function image=generateImage(obj,name)
            image.calib=dlmread(obj.calibPath.getPath(name,obj.path));
            image.depth=dlmread(obj.depthPath.getPath(name,obj.path));
            image.img=obj.imgPath.getPath(name);
            image.objects=searchObjects(obj.annoPath.getPath(name,obj.path));
            tmpRGB=imread([obj.path image.img]);
            tmpSize=size(tmpRGB);
            assert(all(tmpSize(1:2)==size(image.depth)),'RGB and Depth image have different sizes');
            image.imgsize=tmpSize([2 1 3]);

            image.objects=DataHandlers.evaluateDepth(image.objects,image.depth,...
                image.calib,image.imgsize);
        end
        
        function relocateAnnotationFile(obj,name)
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