clear all

countSceneOccurences=false;
countObjectOccurences=true;
showCooccurences=false;

%ildet=DataHandlers.SunDetLoader('../Sun09/dataset');
ildet=DataHandlers.SunDetLoader('./Dataset/Sun09_clean');
ilgt=DataHandlers.SunGTLoader('./Dataset/Sun09_clean');

if countSceneOccurences
    im=ildet.getData(ildet.testSet);

    occCount=zeros(size(ildet.classes));
    classesAvailable={ildet.classes(:).name}';

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
end

if countObjectOccurences
    im=ilgt.getData(ilgt.trainSet);

    occCount=zeros(size(ilgt.classes));
    classesAvailable={ilgt.classes(:).name}';

    for i=1:length(im)
        names={im(i).annotation.object(:).name};
        occCount=occCount+sum(strcmp(classesAvailable(:,ones(1,length(names))),...
            names(ones(length(classesAvailable),1),:)),2);
    end
    
    factor=max(occCount)/length(im)
end

if showCooccurences
    im=[ilgt.getData(ilgt.testSet) ilgt.getData(ilgt.trainSet)];
    
    coocc=zeros(1,1e6);
    sameCoocc=zeros(size(coocc));
    
    for i=1:length(im)
        nObj=length(im(i).annotation.object)+1;
        coocc(nObj)=coocc(nObj)+1;
        for c=1:length(il.objects)
            nSObj=sum(ismember({im(i).annotation.object.name},il.objects(c).name))+1;
            sameCoocc(nSObj)=sameCoocc(nSObj)+1;
        end
    end
    
    semilogy(0:length(coocc)-1,coocc,'r',0:length(sameCoocc)-1,sameCoocc,'b');
end