classdef ObjectDetector%<handle
    %% Properties
    properties(SetAccess='protected')
        classes;
    end
    
    %% Interface
    methods(Abstract)
        detections=detectClass(obj,className,image);
    end
    methods
        function detections=detectAll(obj,image)
            detections=[];
            for i=1:length(obj.classes)
                detections=[detections;obj.detectClass(obj.classes{i},image)];
            end
        end
    end
end