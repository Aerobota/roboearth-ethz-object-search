classdef Object3DStructure<DataHandlers.ObjectStructure
    %OBJECT3DSTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        pos
        dim
    end
    
    methods
        function obj=Object3DStructure(name,polygonX,polygonY,depth,calib)
            obj=obj@DataHandlers.ObjectStructure(name,polygonX,polygonY);
            obj=obj.evaluateDepth(depth,calib);
        end
    end
    
    methods(Access='protected')
        function obj=evaluateDepth(obj,depth,calib)
            mask=poly2mask(obj.polygon.y,...
                obj.polygon.x,size(depth,1),size(depth,2));
            medDepth=median(depth(mask==1 & isnan(depth)==0));
            bbPoints=zeros(3,2);
            bbPoints(:,1)=[min(obj.polygon.x);min(obj.polygon.y);1];
            bbPoints(:,2)=[max(obj.polygon.x);max(obj.polygon.y);1];
            normBBPoints=calib\bbPoints;
            normBBPoints=normBBPoints*medDepth;
            obj.pos=mean(normBBPoints,2);
            obj.dim=[normBBPoints(1,2)-normBBPoints(1,1) normBBPoints(2,2)-normBBPoints(2,1)];
        end
    end
end

