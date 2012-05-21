function record=PASreadrecord(path)
    global imageLoader;
    
    record=imageLoader.getImage(path);
    record.imgname=record.img;
    
    
    for o=1:length(record.objects)
        record.objects(o).class=record.objects(o).name;
        %record.objects(o).flip=false;
        record.objects(o).truncated=false;
        record.objects(o).difficult=false;
        record.objects(o).bbox(1)=min([record.objects(o).polygon.pt.x]);
        record.objects(o).bbox(2)=min([record.objects(o).polygon.pt.y]);
        record.objects(o).bbox(3)=max([record.objects(o).polygon.pt.x]);
        record.objects(o).bbox(4)=max([record.objects(o).polygon.pt.y]);
    end
end