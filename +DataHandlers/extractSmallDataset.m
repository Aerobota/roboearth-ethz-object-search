function extractSmallDataset(inpath,outpath)
    scenesSmallDataset={'kitchen';'office'};
    
    dataPacks{1}=DataHandlers.SunDataStructure(inpath,DataHandlers.SunDataStructure.trainSet,...
        DataHandlers.SunDataStructure.gt);
    dataPacks{2}=DataHandlers.SunDataStructure(inpath,DataHandlers.SunDataStructure.trainSet,...
        DataHandlers.SunDataStructure.det);
    dataPacks{3}=DataHandlers.SunDataStructure(inpath,DataHandlers.SunDataStructure.testSet,...
        DataHandlers.SunDataStructure.gt);
    dataPacks{4}=DataHandlers.SunDataStructure(inpath,DataHandlers.SunDataStructure.testSet,...
        DataHandlers.SunDataStructure.det);
    
    output{1}=DataHandlers.SunDataStructure(outpath,DataHandlers.SunDataStructure.trainSet,...
        DataHandlers.SunDataStructure.gt);
    output{2}=DataHandlers.SunDataStructure(outpath,DataHandlers.SunDataStructure.trainSet,...
        DataHandlers.SunDataStructure.det);
    output{3}=DataHandlers.SunDataStructure(outpath,DataHandlers.SunDataStructure.testSet,...
        DataHandlers.SunDataStructure.gt);
    output{4}=DataHandlers.SunDataStructure(outpath,DataHandlers.SunDataStructure.testSet,...
        DataHandlers.SunDataStructure.det);

%     ilgt=DataHandlers.SunGTLoader(inpath);
%     ildet=DataHandlers.SunDetLoader(inpath);

%     dataPacks={gtTrain,gtTest,detTrain,detTest};
% 
%     output=cell(size(dataPacks,1),1);

    for i=1:length(dataPacks)
        dataPacks{i}.load();
        getSceneData(scenesSmallDataset,dataPacks{i},output{i});
        disp(['loaded ' num2str(i)])
        output{i}=output{i}.removeAliases(output{i});
    end

    classes=dataPacks{1}.getClassNames();
    for i=1:round(length(dataPacks)/2)
        classes=cleanClasses(output{2*i},output{2*i-1},classes);
    end
    disp('cleaned classes')

    for i=1:round(length(dataPacks)/2)
        [output{2*i},output{2*i-1}]=cleanImages(output{2*i},output{2*i-1},classes);
    end
    disp('cleaned images')

    for i=1:length(output)
        getImageFiles(output{i},inpath,outpath);
    end
    disp('copied image files')

    for i=1:length(output)
        output{i}=cleanObjects(output{i},classes);
    end
    disp('cleaned objects')

    if ~exist(outpath,'dir')
        mkdir(outpath);
    end

    for i=1:length(output)
        output{i}.save();
    end

    names=classes;
    save(fullfile(outpath,DataHandlers.SunDataStructure.catFileName),'names');
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

function classes=cleanClasses(det,gt,classes)
    occCount=zeros(size(classes));
    gtCount=zeros(size(classes));
    for i=1:length(det)
        occCount=occCount+ismember(classes,{det.getObject(i).name});
        gtCount=gtCount+ismember(classes,{gt.getObject(i).name});
    end
    classes=classes(gtCount>9 & occCount>max(occCount)*0.9);
end

function [det,gt]=cleanImages(det,gt,classes)
    imageComplete=true(size(det));
    for i=1:length(det)
        imageComplete(i)=all(ismember(classes,{det.getObject(i).name}));
    end
    det=det.getSubset(imageComplete);
    gt=gt.getSubset(imageComplete);
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
    for i=1:length(data)
        tmpObject=data.getObject(i);
        tmpObject=tmpObject(ismember({tmpObject.name},classes));
        data.setObject(tmpObject,i);
    end
end