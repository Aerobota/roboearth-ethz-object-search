classdef HOGDetector<DataHandlers.ObjectDetector
    %% Properties
%     properties(SetAccess='protected')
%         classes;
%     end
    properties(SetAccess='protected')
        threshold;
    end
    properties(Constant)
        modelPath=[pwd '/models/'];
        detectorCodePath=[pwd '/ObjectDetector/'];
    end
    
    %% Interface
    methods
        function obj=HOGDetector(thresh)
            obj.threshold=thresh;
            
            % Ensure that the Felzsenzwalb detector is available
            if(~obj.detectorAvailable())
                addpath(obj.detectorCodePath);
                assert(obj.detectorAvailable,'HOGDetector:detectClass:HOGNotAvailable',...
                    'The system can''t find the HOG detector toolbox');
            end
        end
        function detections=detectClass(obj,className,image)
            % Load correct model
            loaded=load([obj.modelPath className]);
            warning('buffer the model loading process for speed up')
            
            % run detector
            [dets, boxes] = imgdetect(image, loaded.model, obj.threshold);
            bbox = bboxpred_get(loaded.model.bboxpred, dets, reduceboxes(loaded.model, boxes));
            bbox = clipboxes(image, bbox);
            top = nms(bbox, 0.5);
            
            detections(1,length(top)).name=className;
            for i=1:length(top)
                detections(i).name=className;
                detections(i).score=bbox(top(i),end)+obj.threshold;
                detections(i).polygon.x(4,1)=bbox(top(i),1);
                detections(i).polygon.y(4,1)=bbox(top(i),2);
                detections(i).polygon.x(3,1)=bbox(top(i),1);
                detections(i).polygon.y(3,1)=bbox(top(i),4);
                detections(i).polygon.x(2,1)=bbox(top(i),3);
                detections(i).polygon.y(2,1)=bbox(top(i),4);
                detections(i).polygon.x(1,1)=bbox(top(i),3);
                detections(i).polygon.y(1,1)=bbox(top(i),2);
            end
        end
    end
    methods(Static,Access='private')
        function available=detectorAvailable()
            available=exist('imgdetect','file')==2 && exist('bboxpred_get','file')==2 &&...
                    exist('reduceboxes','file')==2 && exist('clipboxes','file')==2 &&...
                    exist('nms','file')==2;
        end
    end
end