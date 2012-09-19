classdef Object3DStructure<DataHandlers.ObjectStructure
    %OBJECT3DSTRUCTURE 3D extension of DATAHANDLERS.OBJECTSTRUCTURE
    %   This class extends the DATAHANDLERS.OBJECTSTRUCTURE to contain a
    %   3D position and dimension.
    %
    %   See also DATAHANDLERS.OBJECTSTRUCTURE.
    
    properties(SetAccess='protected')
        pos
        dim
    end
    
    methods
        function obj=Object3DStructure(name,polygonX,polygonY,depth,calib)
            %OBJ=OBJECT3DSTRUCTURE(NAME,POLYGONX,POLYGONY,POS,DIM)
            %   Generates a 3D object structure.
            %   NAME is the class of the object.
            %   POLIGONX are the vertical pixel coordinates of the bounding
            %   polygon.
            %   POLIGONY are the horizontal pixel coordinates of the bounding
            %   polygon.
            %   POS is a 3x1 vector containing the 3D position of the object.
            %   DIM is a 1x2 vector containing the height and width of the object.
            %
            %OBJ=OBJECT3DSTRUCTURE(NAME,POLYGONX,POLYGONY,DEPTH,CALIB)
            %   This constructor calculates POS and DIM from the DEPTH and
            %   CALIB data.
            %   DEPTH is the depth data of the image.
            %   CALIB is the calibration matrix of the camera.
            
            % call super class constructor
            if nargin==0
                superClassArgs=cell(1,0);
            else
                superClassArgs={name,polygonX,polygonY};
            end
            obj=obj@DataHandlers.ObjectStructure(superClassArgs{:});
            
            if nargin>=5
                if isvector(depth) && isvector(calib)
                    % First version of constructor
                    assert(isnumeric(depth) && all(size(depth)==[3 1]),'DataStructure:wrongInput',...
                        'The depth argument must be a 3x1 vector representing the 3D-coordinates of the object.')
                    assert(isnumeric(calib) && all(size(calib)==[1 2]),'DataStructure:wrongInput',...
                        'The calib argument must be a 1x2 vector representing the dimensions of the object.')
                    obj.pos=depth;
                    obj.dim=calib;
                else
                    % Second version of the constructor
                    assert(isnumeric(depth),'DataStructure:wrongInput',...
                        'The depth argument must be a matrix.')
                    assert(min(polygonX)>0 && min(polygonY)>0 && max(polygonX)<=size(depth,1)...
                        && max(polygonY)<=size(depth,2),'ObjectStructure:badInput',...
                        'The bounding polygon lies outside of the depth image.')
                    assert(isnumeric(calib) && all(size(calib)==[3 3]),'DataStructure:wrongInput',...
                        'The calib argument must be a 3x3 matrix.')

                    obj=obj.evaluateDepth(depth,calib);
                end
            end
        end
    end
    
    methods(Access='protected')
        function obj=evaluateDepth(obj,depth,calib)
            % Get all pixels inside the bounding polygon
            mask=poly2mask(obj.polygon.y,...
                obj.polygon.x,size(depth,1),size(depth,2));
            % Calculate the median depth
            medDepth=median(depth(mask==1 & isnan(depth)==0));
            % Generate opposing corner points of bounding box
            bbPoints=zeros(3,2);
            bbPoints(:,1)=[min(obj.polygon.x);min(obj.polygon.y);1];
            bbPoints(:,2)=[max(obj.polygon.x);max(obj.polygon.y);1];
            % Transform to 3D
            normBBPoints=calib\bbPoints;
            normBBPoints=normBBPoints*medDepth;
            % Get centre and dimensions
            obj.pos=mean(normBBPoints,2);
            obj.dim=[normBBPoints(1,2)-normBBPoints(1,1) normBBPoints(2,2)-normBBPoints(2,1)];
        end
    end
end

