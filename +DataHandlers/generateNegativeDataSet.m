function generateNegativeDataSet(inpath,outpath)
    scenes={'outdoor','road','street','mountain'};
    maxNum=600;
    
    ilgt=DataHandlers.SunGTLoader(inpath);
    
    dataPacks=[{ilgt} ilgt.trainSet];
    
    output=cell(size(dataPacks,1),1);
    
    for i=1:size(dataPacks,1)
        output{i}=getSceneData(scenes,dataPacks{i,1},dataPacks(i,2:end),maxNum);
        disp(['loaded ' dataPacks{i,2} ' ' dataPacks{i,3}])
    end
    
    for i=1:size(dataPacks,1)
        getImageFiles(output{i},inpath,outpath);
    end
    disp('copied image files')
    
    if ~exist(outpath,'dir')
        mkdir(outpath);
    end
    
    for i=1:size(dataPacks,1)
        tmpData.(dataPacks{i,2})=output{i};
        filePath=fullfile(outpath,dataPacks{i,3});
        if exist(filePath,'file')
            save(filePath,'-struct','tmpData','-append');
        else
            save(filePath,'-struct','tmpData');
        end
        disp(['saved ' filePath])
        clear tmpData;
    end
    
    [~,~,~]=copyfile(fullfile(inpath,'sun09_objectCategories.mat'),...
        fullfile(outpath,'sun09_objectCategories.mat'));
end



function out=getSceneData(scenes,loader,part,maxNum)
    im=loader.getData(part);

    sceneSelection=false(size(im));
    count=0;
    indices=randperm(length(im));
    for i=indices
        for s=1:length(scenes)
            if ~isempty(strfind(im(i).annotation.filename,scenes{s}))
                sceneSelection(i)=true;
                count=count+1;
            end
            if count>=maxNum
                break
            end
        end
    end
    out=im(sceneSelection);
end

function getImageFiles(data,inPath,outPath)
    for i=1:length(data)
        inImg=fullfile(inPath,'Images',data(i).annotation.folder,data(i).annotation.filename);
        outDir=fullfile(outPath,'image',data(i).annotation.folder);
        outImg=fullfile(outDir,data(i).annotation.filename);
        if exist(inImg,'file') && ~exist(outImg,'file')
            if ~exist(outDir,'dir')
                [~,~,~]=mkdir(outDir);
            end
            [~,~,~]=copyfile(inImg,outImg);
        end
    end
end