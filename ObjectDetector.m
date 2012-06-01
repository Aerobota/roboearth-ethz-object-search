classdef ObjectDetector%<handle
    %% Properties
    properties(SetAccess='protected')
        classes;
    end
    
    %% Interface
    methods(Abstract)
        detections=detectAll(obj,image);
        detections=detectClass(obj,className,image);
    end
    
end