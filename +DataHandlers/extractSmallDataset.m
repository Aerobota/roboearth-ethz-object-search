function extractSmallDataset(inpath,outpath)
    scenesSmallDataset={'kitchen';'office'};
    
    dataPacks{1}=DataHandlers.SunDataStructure(inpath,'train');
    dataPacks{2}=DataHandlers.SunDataStructure(inpath,'test');
    
    output{1}=DataHandlers.SunDataStructure(outpath,'train');
    output{2}=DataHandlers.SunDataStructure(outpath,'test');

    for i=1:length(dataPacks)
        dataPacks{i}.load();
        getSceneData(scenesSmallDataset,dataPacks{i},output{i});
        disp(['loaded ' num2str(i)])
        output{i}=DataHandlers.removeAliases(output{i});
    end

    classes=dataPacks{1}.getClassNames();
    for i=1:length(dataPacks)
        classes=cleanClasses(output{i},classes);
    end
    disp('cleaned classes')

    for i=1:length(output)
        output{i}=cleanObjects(output{i},classes);
    end
    disp('cleaned objects')

    for i=1:length(output)
        getImageFiles(output{i},inpath,outpath);
    end
    disp('copied image files')
    
    if ~exist(outpath,'dir')
        mkdir(outpath);
    end

    for i=1:length(output)
        output{i}.save();
    end

    names=classes;
    smallNames=DataHandlers.extractSmallClasses(classes);
    largeNames=setdiff(classes,smallNames);
    save(fullfile(outpath,DataHandlers.SunDataStructure.catFileName),'names','smallNames','largeNames');
end

function getSceneData(scenes,input,output)
    sceneSelection=false(size(input));
    for i=1:length(input)
        for s=1:length(scenes)
            if ~isempty(strfind(input.getFilename(i),scenes{s}))
                sceneSelection(i)=true;
            end
        end
    end
    
    cIndex=1;
    for i=1:length(input)
        if sceneSelection(i)
            output.addImage(cIndex,input.getFilename(i),input.getDepthname(i),...
                input.getFolder(i),input.getImagesize(i),input.getObject(i),input.getCalib(i));
            cIndex=cIndex+1;
        end
    end
end

function classes=cleanClasses(gt,classes)
    gtCount=zeros(size(classes));
    for i=1:length(gt)
        gtCount=gtCount+ismember(classes,{gt.getObject(i).name});
    end
    classes=classes(gtCount>9);
end

function getImageFiles(data,inPath,outPath)
    for i=1:length(data)
        inImg=fullfile(inPath,data.imageFolder,data.getFolder(i),data.getFilename(i));
        outDir=fullfile(outPath,data.imageFolder,data.getFolder(i));
        outImg=fullfile(outDir,data.getFilename(i));
        if exist(inImg,'file') && ~exist(outImg,'file')
            if ~exist(outDir,'dir')
                [~,~,~]=mkdir(outDir);
            end
            [~,~,~]=copyfile(inImg,outImg);
        end
    end
end

function data=cleanObjects(data,classes)
    goodData=true(size(data));
    for i=1:length(data)
        tmpObject=data.getObject(i);
        tmpObject=tmpObject(ismember({tmpObject.name},classes));
        if isempty(tmpObject)
            goodData(i)=false;
        end
        data.setObject(tmpObject,i);
    end
    data.reduceDataStructure(goodData);
end