clear all

%il=DataHandlers.SunLoader('../Sun09/dataset');
il=DataHandlers.SunLoader('./Sun09_small');
im=il.getData(il.detTest);

occCount=zeros(size(il.objects));
classesAvailable={il.objects(:).name}';

%scenes={'kitchen','living','bath','dining','indoor'};
scenes={'kitchen';'office'};
sceneCounts=zeros(size(scenes));
sceneSelection= false(size(im));

for i=1:length(im)
    for s=1:length(scenes)
        if ~isempty(strfind(im(i).annotation.filename,scenes{s}))
            sceneSelection(i)=true;
            sceneCounts(s)=sceneCounts(s)+1;
        end
    end
    
    occCount=occCount+ismember(classesAvailable,{im(i).annotation.object(:).name});
end

sum(sceneSelection)

out=im(sceneSelection);