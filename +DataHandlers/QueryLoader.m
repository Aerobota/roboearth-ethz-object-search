classdef QueryLoader<DataHandlers.DistributedDataLoader
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
            obj=obj@DataHandlers.DistributedDataLoader(filePath,false);
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
        function image=loadData(obj,name)
            image=obj.imageDataLoader.getDataByName(name);
                
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
                tmpRGB=imread([obj.imageDataLoader.path image.annotation.img]);
                detections=obj.detector.detectAll(tmpRGB);
                
                detections=DataHandlers.evaluateDepth(detections,image.annotation.depth,...
                    image.annotation.calib,image.annotation.imagesize);
                
                if ~exist([obj.path obj.queryPath.path],'dir')
                    [~,~,~]=mkdir([obj.path obj.queryPath.path]);
                end

                save(longQueryPath,'detections');
            end
            
            image.annotation.object=detections;
        end
    end
end