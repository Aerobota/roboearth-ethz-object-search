dataPath='Dataset/OfficeTraining';
il=DataHandlers.GroundTruthLoader(dataPath);

names={};
for i=1:il.nrImgs
    im=il.getData(i);
    names=[names(:)' {im.objects.name}];
end

classes=unique(names);
% positions=cell(il.nrImgs,length(classes));
% 
% for i=1:il.nrImgs
%     im=il.getImage(i);
%     for o=1:length(im.objects)
%         tmpInd=find(strcmp(im.objects(o).name,classes)==1);
%         positions{i,tmpInd}=[positions{i,tmpInd} im.objects(o).pos];
%     end
% end

dist=cell(length(classes),length(classes));
for i=1:il.nrImgs
    im=il.getData(i);
    dist=relativeDistances(im,classes,dist);
%     for o=1:length(im.objects)
%         for t=o+1:length(im.objects)
%             ind=[find(strcmp(im.objects(o).name,classes)==1)...
%                 find(strcmp(im.objects(t).name,classes)==1);];
%             newDist=[sqrt(sum((im.objects(o).pos([1 3])-im.objects(t).pos([1 3])).^2));...
%                 im.objects(o).pos(2)-im.objects(t).pos(2)];
%             if(ind(1)>ind(2))
%                 dist{ind(2),ind(1)}=[dist{ind(2),ind(1)}...
%                     [newDist(1);-newDist(2)]];
%             else
%                 dist{ind(1),ind(2)}=[dist{ind(1),ind(2)} newDist];
%             end
%         end
%     end
end
     