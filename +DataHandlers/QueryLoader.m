classdef QueryLoader<DataHandlers.DataLoader%<DataHandlers.GroundTruthLoader
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(Constant,GetAccess='protected')
        queryPath=DataHandlers.CompoundPath('queryImage_','query','.mat');
        imageDataLoader=@DataHandlers.GroundTruthLoader;
    end
    properties(SetAccess='protected')
        detector;
    end
    
    %% Public Methods
    methods
        function obj=QueryLoader(filePath,objectDetector)
            obj=obj@DataHandlers.DataLoader(filePath);
            obj.detector=objectDetector;
        end
        
        function clean(obj)
            [~,~,~]=rmdir([obj.path obj.queryPath.path],'s');
        end
    end
    
    %% Private Methods
    methods(Access='protected')
        function detections=loadData(obj,name)
            longQueryPath=obj.queryPath.getPath(name,obj.path);

            goodQueryMat=false;

            if exist(longQueryPath,'file')
                loaded=load(longQueryPath);
                detections=loaded.detections;
                goodQueryMat=isfield(detections,'class') && isfield(detections,'pos') &&...
                    isfield(detections,'dim') && isfield(detections,'score') &&...
                    isfield(detections,'polygon');
            end
            
            if ~goodQueryMat
                tmpLoader=obj.imageDataLoader(obj.path);
                image=tmpLoader.getData(name);
                tmpRGB=imread([obj.path image.img]);
                detections=obj.detector.detectAll(tmpRGB);
                
                detections=DataHandlers.evaluateDepth(detections,image.depth,image.calib,image.imgsize);
                
                if ~exist([obj.path obj.queryPath.path],'dir')
                    [~,~,~]=mkdir([obj.path obj.queryPath.path]);
                end

                save(longQueryPath,'detections');
            end
            
            image.detections=detections;
        end
    end
end