classdef Learner<handle
    %LEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        classes
    end
    methods
        function obj=Learner(classes)
            obj.classes=genvarname(classes);
        end
    end
    
end

