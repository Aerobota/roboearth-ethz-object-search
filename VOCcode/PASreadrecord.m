function record=PASreadrecord(path)
    global imageData;
    i=imageData.name2Index(path);
    record.imgname=fullfile(imageData.imageFolder,imageData.getFolder(i),...
        imageData.getFilename(i));
    
    tmpObjects=imageData.getObject(i);
    for o=1:length(tmpObjects)
        record.objects(o).class=tmpObjects(o).name;
        record.objects(o).truncated=false;
        record.objects(o).difficult=false;
        record.objects(o).bbox(1)=min([tmpObjects(o).polygon.y]);
        record.objects(o).bbox(2)=min([tmpObjects(o).polygon.x]);
        record.objects(o).bbox(3)=max([tmpObjects(o).polygon.y]);
        record.objects(o).bbox(4)=max([tmpObjects(o).polygon.x]);
        record.imgsize=[imageData.getImagesize(i).ncols imageData.getImagesize(i).nrows];
    end
end