function [pos, neg] = load_data(cls, DatasetPath)

    loader=ImageLoader(DatasetPath);
    splitMask=zeros(loader.nrImgs,1);
    for i=1:length(splitMask)
        tmpImg=loader.getImage(i);
        for o=1:length(tmpImg.objects)
            if(strcmp(tmpImg.objects(o).name,cls)==1)
                splitMask(i)=splitMask(i)+1;
            end
        end
    end

    nrPos=sum(splitMask);
    nrNeg=length(splitMask)-nrPos;

    if nrPos>0
        pos(nrPos).flip=false;
    else
        pos=[];
    end
    if nrNeg>0
        neg(nrNeg).flip=false;
    else
        neg=[];
    end

    cPosI=1;
    cNegI=1;

    for i=1:length(splitMask)
        tmpImg=loader.getImage(i);
        if(splitMask(i)>0)
            for o=1:length(tmpImg.objects)
                if(strcmp(tmpImg.objects(o).name,cls)==1)
                    pos(cPosI).im=tmpImg.img;
                    pos(cPosI).flip=false;
                    pos(cPosI).trunc=false;
                    pos(cPosI).x1=min([tmpImg.objects(o).polygon.pt.x]);
                    pos(cPosI).x2=max([tmpImg.objects(o).polygon.pt.x]);
                    pos(cPosI).y1=min([tmpImg.objects(o).polygon.pt.y]);
                    pos(cPosI).y2=max([tmpImg.objects(o).polygon.pt.y]);
                    cPosI=cPosI+1;
                end
            end
        else
            neg(cNegI).im=tmpImg.img;
            neg(cNegI).flip=false;
        end

    end
end
