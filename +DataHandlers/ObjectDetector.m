classdef ObjectDetector<handle
    %% Interface
    methods(Abstract)
        detections=detectClass(obj,className,image);
    end
end