classdef ObjectStructure<handle
    %OBJECTSTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    properties(SetAccess='protected')
        name
        polygon
    end
    methods
        function obj=ObjectStructure(name,polygonX,polygonY)
            assert(ischar(name),'ObjectStructure:wrongInput',...
                'The name argument must be a character array.')
            assert(isvector(polygonX) && isnumeric(polygonX),'ObjectStructure:wrongInput',...
                'The polygonX argument must be a numeric vector.')
            assert(isvector(polygonY) && isnumeric(polygonY),'ObjectStructure:wrongInput',...
                'The polygonY argument must be a numeric vector.')
            assert(all(size(polygonX)==size(polygonY)),'ObjectStructure:wrongInput',...
                'The polygonX and polygonY arguments must be of same size.')
            
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

