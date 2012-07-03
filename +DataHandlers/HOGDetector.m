classdef HOGDetector<DataHandlers.ObjectDetector
    %% Properties
    properties(SetAccess='protected')
        threshold;
        models;
        modelPath
    end
    properties(Constant)
        detectorCodePath=fullfile(pwd,'ObjectDetector');
        modelTag='.mat'
    end
    
    %% Public methods
    methods
        function obj=HOGDetector(thresh,modelPath)
            obj.threshold=thresh;
            obj.modelPath=modelPath;
            
            % Ensure that the Felzsenzwalb detector is available
            if(~obj.detectorAvailable())
                addpath(obj.detectorCodePath);
                assert(obj.detectorAvailable(),'HOGDetector:detectClass:HOGNotAvailable',...
                    'The system can''t find the HOG detector toolbox');
            end
        end
        function detections=detectClass(obj,className,image)
            % Load correct model
            model=obj.loadModel(className);
            
            % run detector
            [~, bbox] = imgdetect(image, model, obj.threshold);
            bbox = clipboxes(image, bbox);
            top = nms(bbox, 0.5);
            
            if ~isempty(top)
                for i=length(top):-1:1
                    tmpX(4,1)=bbox(top(i),2);
                    tmpY(4,1)=bbox(top(i),1);
                    tmpX(3,1)=bbox(top(i),2);
                    tmpY(3,1)=bbox(top(i),3);
                    tmpX(2,1)=bbox(top(i),4);
                    tmpY(2,1)=bbox(top(i),3);
                    tmpX(1,1)=bbox(top(i),4);
                    tmpY(1,1)=bbox(top(i),1);
                    detections(i)=DataHandlers.ObjectStructure(className,bbox(top(i),end),tmpX,tmpY);
                end
            else
                detections=[];
            end
        end
    end
    %% Private methods
    methods(Static,Access='private')
        function available=detectorAvailable()
            available=exist('imgdetect','file')==2 && exist('bboxpred_get','file')==2 &&...
                    exist('reduceboxes','file')==2 && exist('clipboxes','file')==2 &&...
                    exist('nms','file')==2;
        end
    end
    methods(Access='protected')
        function model=loadModel(obj,class)
            try
                model=obj.models.(class);
            catch
                loaded=load(fullfile(obj.modelPath,[class obj.modelTag]));
                model=loaded.model;
                obj.models.(class)=model;
            end
        end
    end
end