function objects=evaluateDepth(objects,depth,calib,imgsize)
    for o=1:length(objects)
        mask=poly2mask([objects(o).polygon.pt(:).x],...
            [objects(o).polygon.pt(:).y],imgsize(2),imgsize(1));
        medDepth=median(depth(mask==1 & isnan(depth)==0));
        bbPoints=zeros(3,2);
        bbPoints(:,1)=[min([objects(o).polygon.pt.x]);min([objects(o).polygon.pt.y]);1];
        bbPoints(:,2)=[max([objects(o).polygon.pt.x]);max([objects(o).polygon.pt.y]);1];
        normBBPoints=calib\bbPoints;
        normBBPoints=normBBPoints*medDepth;
        objects(o).pos=mean(normBBPoints,2);
        objects(o).dim=[normBBPoints(1,2)-normBBPoints(1,1) normBBPoints(2,2)-normBBPoints(2,1)];
    end
end