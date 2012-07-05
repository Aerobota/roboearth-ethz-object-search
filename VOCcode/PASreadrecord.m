function record=PASreadrecord(path)
    global imageLoader;
    tmpData=imageLoader.getDataByName(path);
    record.imgname=fullfile(imageLoader.imageFolder,tmpData.getFolder(1),...
        tmpData.getFilename(1));
    
    tmpObjects=tmpData.getObject(1);
    for o=1:length(tmpObjects)
        record.objects(o).class=tmpObjects(o).name;
        record.objects(o).truncated=false;
        record.objects(o).difficult=false;
        record.objects(o).bbox(1)=min([tmpObjects(o).polygon.y]);
        record.objects(o).bbox(2)=min([tmpObjects(o).polygon.x]);
        record.objects(o).bbox(3)=max([tmpObjects(o).polygon.y]);
        record.objects(o).bbox(4)=max([tmpObjects(o).polygon.x]);
        record.imgsize=[tmpData.getImagesize(1).ncols tmpData.getImagesize(1).nrows];
    end
end