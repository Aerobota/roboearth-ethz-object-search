function dist=relativeDistances(image,classes,dist)
    if nargin<3
        dist=cell(length(classes),length(classes));
    end
    for o=1:length(image.objects)
        for t=o+1:length(image.objects)
            ind=[find(strcmp(image.objects(o).name,classes)==1)...
                find(strcmp(image.objects(t).name,classes)==1);];
            newDist=[sqrt(sum((image.objects(o).pos([1 3])-image.objects(t).pos([1 3])).^2));...
                image.objects(o).pos(2)-image.objects(t).pos(2)];
            if(ind(1)>ind(2))
                dist{ind(2),ind(1)}=[dist{ind(2),ind(1)}...
                    [newDist(1);-newDist(2)]];
            else
                dist{ind(1),ind(2)}=[dist{ind(1),ind(2)} newDist];
            end
        end
    end
end