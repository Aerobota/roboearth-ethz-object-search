function generateSmallDataSet(inpath,outpath)
    scenes={'kitchen';'office'};
    
    il=DataHandlers.SunLoader(inpath);
    
    dataPacks={il.detTrain{:};il.gtTrain{:};il.detTest{:};il.gtTest{:}};
    
    output=cell(size(dataPacks,1),1);
    
    for i=1:size(dataPacks,1)
        output{i}=getSceneData(scenes,il,dataPacks(i,:));
        disp(['loaded ' dataPacks{i,1} ' ' dataPacks{i,2}])
        output{i}=removeAliases(output{i});
    end
    
    classes={il.objects(:).name};
    for i=1:round(size(dataPacks,1)/2)
        classes=cleanClasses(output{2*i-1},output{2*i},classes);
    end
    disp('cleaned classes')
    
    for i=1:round(size(dataPacks,1)/2)
        [output{2*i-1},output{2*i}]=cleanImages(output{2*i-1},output{2*i},classes);
    end
    disp('cleaned images')
    
    for i=1:size(dataPacks,1)
        output{i}=cleanObjects(output{i},classes);
    end
    disp('cleaned objects')
    
    if ~exist(outpath,'dir')
        mkdir(outpath);
    end
    
    for i=1:size(dataPacks,1)
        tmpData.(dataPacks{i,1})=output{i};
        filePath=fullfile(outpath,dataPacks{i,2});
        if exist(filePath,'file')
            save(filePath,'-struct','tmpData','-append');
        else
            save(filePath,'-struct','tmpData');
        end
        disp(['saved ' filePath])
        clear tmpData;
    end
    
    names={il.objects(ismember({il.objects(:).name},classes)).name};
    heights=[il.objects(ismember({il.objects(:).name},classes)).height];
    save(fullfile(outpath,il.catFileName),'names','heights');
end



function out=getSceneData(scenes,loader,part)
    im=loader.getData(part);

    sceneSelection=false(size(im));

    for i=1:length(im)
        for s=1:length(scenes)
            if ~isempty(strfind(im(i).annotation.filename,scenes{s}))
                sceneSelection(i)=true;
            end
        end
    end
    out=im(sceneSelection);
end

function classes=cleanClasses(det,gt,classes)
    occCount=zeros(size(classes));
    gtCount=zeros(size(classes));
    for i=1:length(det)
        occCount=occCount+ismember(classes,{det(i).annotation.object(:).name});
        gtCount=gtCount+ismember(classes,{gt(i).annotation.object(:).name});
    end
    classes=classes(gtCount>9 & occCount>max(occCount)*0.9);
end

function [det,gt]=cleanImages(det,gt,classes)
    imageComplete=true(size(det));
    for i=1:length(det)
        imageComplete(i)=all(ismember(classes,{det(i).annotation.object.name}));
    end
    det=det(imageComplete);
    gt=gt(imageComplete);
end

function data=cleanObjects(data,classes)
    for i=1:length(data)
        data(i).annotation.object=data(i).annotation.object(ismember({data(i).annotation.object.name},classes));
    end
end

function data=removeAliases(data)
    alias.books='book';
    alias.bottles='bottle';
    alias.boxes='box';
    alias.cars='car';
    alias.rocks='stone';
    alias.rock='stone';
    alias.stones='stone';
    alias.pillow='cushion';
    alias.monitor='screen';
    
    for i=1:length(data)
        for o=1:length(data(i).annotation.object)
            try
                data(i).annotation.object(o).name=alias.(data(i).annotation.object(o).name);
            catch
            end
        end
    end
end