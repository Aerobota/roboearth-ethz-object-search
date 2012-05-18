function [pos, neg] = pascal_data(cls, flippedpos, year)

% [pos, neg] = pascal_data(cls)
% Get training data from the PASCAL dataset.

% setVOCyear = year;
globals; 
%pascal_init;

if nargin < 2
  flippedpos = false;
end

% try
%     load([cachedir cls '_train_' year]);
% catch
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
    pos(nrPos).il=loader;
else
    pos=[];
end
if nrNeg>0
    neg(nrNeg).il=loader;
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
                pos(cPosI).il=loader;
                pos(cPosI).imIndex=i;
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
        neg(cNegI).il=loader;
        neg(cNegI).imIndex=i;
        neg(cNegI).flip=false;
    end

end
%   
%     save([cachedir cls '_train_' year], 'pos', 'neg');
% end

% pos.x1,pos.x2,pos.y1,pos.y2,pos.flip,pos.trunc,pos.loader,pos.imIndex
% neg.flip,neg.loader,neg.imIndex
