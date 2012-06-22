function objects=evaluateDepth(objects,depth,calib) % ,imgsize is not necessary
    for o=1:length(objects)
        mask=poly2mask(objects(o).polygon.x,...
            objects(o).polygon.y,size(depth,1),size(depth,2));
        medDepth=median(depth(mask==1 & isnan(depth)==0));
        bbPoints=zeros(3,2);
        bbPoints(:,1)=[min(objects(o).polygon.x);min(objects(o).polygon.y);1];
        bbPoints(:,2)=[max(objects(o).polygon.x);max(objects(o).polygon.y);1];
        normBBPoints=calib\bbPoints;
        normBBPoints=normBBPoints*medDepth;
        objects(o).pos=mean(normBBPoints,2);
        objects(o).dim=[normBBPoints(1,2)-normBBPoints(1,1) normBBPoints(2,2)-normBBPoints(2,1)];
    end
end