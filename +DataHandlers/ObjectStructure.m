classdef ObjectStructure
    %OBJECTSTRUCTURE Contains all information about a single object
    %   Saves the class name of the object in NAME and the bounding polygon
    %   in POLYGON.
    properties(SetAccess='protected')
        name
        polygon
    end
    methods
        function obj=ObjectStructure(name,polygonX,polygonY)
            %OBJ=OBJECTSTRUCTURE(NAME,POLYGONX,POLYGONY)
            %   Generates an object structure.
            %   NAME is the class of the object.
            %   POLIGONX are the vertical pixel coordinates of the bounding
            %   polygon.
            %   POLIGONY are the horizontal pixel coordinates of the bounding
            %   polygon.
            if nargin==0
                obj.name='DummyObject';
            else
                assert(ischar(name),'ObjectStructure:wrongInput',...
                    'The name argument must be a character array.')
                assert(isvector(polygonX) && isa(polygonX,'double'),'ObjectStructure:wrongInput',...
                    'The polygonX argument must be a double vector.')
                assert(isvector(polygonY) && isa(polygonY,'double'),'ObjectStructure:wrongInput',...
                    'The polygonY argument must be a double vector.')
                assert(all(size(polygonX)==size(polygonY)),'ObjectStructure:wrongInput',...
                    'The polygonX and polygonY arguments must be of same size.')

                obj.name=genvarname(name);

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
end

