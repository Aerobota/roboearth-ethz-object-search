function record=PASreadrecord(path)
    global imageLoader;
    record=imageLoader.getDataByName(path);
    record.imgname=fullfile(imageLoader.imageFolder,record.annotation.folder,...
        record.annotation.filename);
    
    for o=1:length(record.annotation.object)
        record.objects(o).class=record.annotation.object(o).name;
        %record.objects(o).flip=false;
        record.objects(o).truncated=false;
        record.objects(o).difficult=false;
        record.objects(o).bbox(1)=min([record.annotation.object(o).polygon.x]);
        record.objects(o).bbox(2)=min([record.annotation.object(o).polygon.y]);
        record.objects(o).bbox(3)=max([record.annotation.object(o).polygon.x]);
        record.objects(o).bbox(4)=max([record.annotation.object(o).polygon.y]);
        record.imgsize=[record.annotation.imagesize.ncols record.annotation.imagesize.nrows];
    end
end