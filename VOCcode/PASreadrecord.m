function record=PASreadrecord(path)
    global imageLoader;
    tmpData=imageLoader.getDataByName(path);
    record.imgname=fullfile(imageLoader.imageFolder,tmpData.getFolder(1),...
        tmpData.getFilename(1));
    
    for o=1:length(tmpData.getObject(1))
        record.objects(o).class=tmpData.getObject(1,o).name;
        record.objects(o).truncated=false;
        record.objects(o).difficult=false;
        record.objects(o).bbox(1)=min([tmpData.getObject(1,o).polygon.y]);
        record.objects(o).bbox(2)=min([tmpData.getObject(1,o).polygon.x]);
        record.objects(o).bbox(3)=max([tmpData.getObject(1,o).polygon.y]);
        record.objects(o).bbox(4)=max([tmpData.getObject(1,o).polygon.x]);
        record.imgsize=[tmpData.getImagesize(1).ncols tmpData.getImagesize(1).nrows];
    end
end