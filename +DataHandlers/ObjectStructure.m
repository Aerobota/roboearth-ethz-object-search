classdef ObjectStructure<handle
    %OBJECTSTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    properties(SetAccess='protected')
        name
        polygon
    end
    methods
        function obj=ObjectStructure(name,polygonX,polygonY)
            obj.name=name;
            
            if size(polygonX,1)==1
                obj.polygon.x=polygonX';
            else
                obj.polygon.x=polygonX;
            end
            
            if size(polygonY,1)==1
                obj.polygon.y=polygonY';
            else
                obj.polygon.y=polygonY;
            end
        end
    end
end

