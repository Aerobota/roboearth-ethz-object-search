classdef QueryLoader<GroundTruthLoader
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(Constant,GetAccess='protected')
        queryPath=CompoundPath('queryImage_','query','.mat');
    end
    properties(SetAccess='protected')
        detector;
    end
    
    %% Public Methods
    methods
        function obj=QueryLoader(filePath,objectDetector)
            %warning('QueryLoader','QueryLoader is not implemented yet');
            obj=obj@GroundTruthLoader(filePath);
            obj.detector=objectDetector;
        end
        
        function clean(obj)
            [~,~,~]=rmdir([obj.path obj.queryPath.path],'s');
        end
    end
    
    %% Private Methods
    methods(Access='protected')
        function image=loadImage(obj,name)
            longQueryPath=obj.queryPath.getPath(name,obj.path);
            longCombPath=obj.combPath.getPath(name,obj.path);

            goodQueryMat=false;
            goodCombMat=false;

            if exist(longQueryPath,'file')
                loaded=load(longQueryPath);
                detections=loaded.detections;
                goodQueryMat=isfield(detections,'class') && isfield(detections,'pos') &&...
                    isfield(detections,'size') && isfield(detections,'score');
            end
            
            if exist(longCombPath,'file')
                image=load(longCombPath);
                goodCombMat=isfield(image,'calib') && isfield(image,'depth') &&...
                    isfield(image,'img') && isfield(image,'objects') &&...
                    isfield(image,'imgsize');
            end

            if ~goodCombMat
                if obj.checkCompleteness(name)
                    image=obj.generateImage(name);
                    if ~exist([obj.path obj.combPath.path],'dir')
                        [~,~,~]=mkdir([obj.path obj.combPath.path]);
                    end
                    
                    save(longCombPath,'-struct','image');
                end
            end
            
            if ~goodQueryMat
                tmpRGB=imread([obj.path image.img]);
                detections=obj.detector.detectAll(tmpRGB);
                
                detections=obj.evaluateDepth(detections,image.depth,image.calib,image.imgsize);
                
                if ~exist([obj.path obj.queryPath.path],'dir')
                    [~,~,~]=mkdir([obj.path obj.queryPath.path]);
                end

                save(longQueryPath,'detections');
            end
            
            image.detections=detections;
        end
    end
end