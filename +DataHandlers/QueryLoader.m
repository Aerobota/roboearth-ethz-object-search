classdef QueryLoader<DataHandlers.DataLoader
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(Constant,GetAccess='protected')
        queryPath=DataHandlers.CompoundPath('queryImage_','query','.mat');
    end
    properties(SetAccess='protected')
        detector;
        imageDataLoader;
    end
    
    %% Public Methods
    methods
        function obj=QueryLoader(filePath,objectDetector,groundTruthLoader)
            obj=obj@DataHandlers.DataLoader(filePath);
            obj.detector=objectDetector;
            if nargin<3
                groundTruthLoader=DataHandlers.GroundTruthLoader(filePath);
            end
            obj.imageDataLoader=groundTruthLoader;
        end
        
        function clean(obj)
            [~,~,~]=rmdir([obj.path obj.queryPath.path],'s');
            obj.imageDataLoader.clean();
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
                image=obj.imageDataLoader.getData(name);
                tmpRGB=imread([obj.imageDataLoader.path image.img]);
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