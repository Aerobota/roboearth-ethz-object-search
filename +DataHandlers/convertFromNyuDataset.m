function convertFromNyuDataset(nyuPath,targetPath)
    convertNyu(nyuPath,targetPath);
end

function convertNyu(inPath,outPath)
    inFile=fullfile(inPath,'nyu_depth_v2_labeled.mat');

    tmp_imageFolder=fullfile(outPath,DataHandlers.NYUDataStructure.imageFolder);
    tmp_depthFolder=fullfile(outPath,DataHandlers.NYUDataStructure.depthFolder);

    disp('extracting images')
    [imageNames,depthNames]=extractImages...
        (inFile,tmp_imageFolder,tmp_depthFolder);

    disp('loading other data')
    tmp_data=load(inFile,'labels','names');
    tmp_data=DataHandlers.removeAliases(tmp_data);
    disp('splitting dataset')
    split=rand(size(tmp_data.labels,3),1)<0.5;
    disp('extracting good classes')
    classes=extractGoodClasses(tmp_data.labels,tmp_data.names,outPath);

    extractObjects(split,imageNames,...
        depthNames,tmp_data.labels,tmp_data.names,classes,outPath,tmp_depthFolder)

end

function [imageNames,depthNames]=extractImages(inFile,tmp_imageFolder,tmp_depthFolder)
    imageName='img_%05d.jpg';
    depthName='depth_%05d.mat';
    disp('loading image data')
    if ~exist(tmp_imageFolder,'dir')
        [~,~,~]=mkdir(tmp_imageFolder);
    end
    tmp_data=load(inFile,'images');

    disp('saving images')
    imageNames=cell(1,size(tmp_data.images,4));
    for i=1:size(tmp_data.images,4)
        imageNames{i}=sprintf(imageName,i);
        imwrite(tmp_data.images(:,:,:,i),fullfile(tmp_imageFolder,imageNames{i}));
    end

    clear('tmp_data')

    disp('loading depth data')
    if ~exist(tmp_depthFolder,'dir')
        [~,~,~]=mkdir(tmp_depthFolder);
    end
    tmp_data=load(inFile,'depths');

    disp('saving depth')
    depthNames=cell(1,size(tmp_data.depths,3));
    for i=1:size(tmp_data.depths,3)
        depthNames{i}=sprintf(depthName,i);
        depth=tmp_data.depths(:,:,i);
        save(fullfile(tmp_depthFolder,depthNames{i}),'depth')
    end
end

function tmp_names=extractGoodClasses(labels,tmp_names,outPath)
    counts=zeros(size(tmp_names));
    numbers=(1:length(tmp_names))';
    for i=1:size(labels,3)
        counts=counts+ismember(numbers,labels(:,:,i));
    end
    tmp_names=tmp_names(counts>100)';
    tmpSave.names=tmp_names;
    tmpSave.smallNames=DataHandlers.extractSmallClasses(tmp_names);
    tmpSave.largeNames=setdiff(tmp_names,tmpSave.smallNames);
    save(fullfile(outPath,DataHandlers.NYUDataStructure.catFileName),'-struct','tmpSave');
end

function extractObjects(split,imageNames,depthNames,labels,allNames,goodClasses,outPath,tmp_depthFolder)
    disp('extracting training set')
    data=DataHandlers.NYUDataStructure(outPath,'train');
    extractImageSet(data,imageNames(1,split),depthNames(1,split),labels(:,:,split),allNames,goodClasses,tmp_depthFolder);
    data.save();

    clear('data')

    disp('extracting test set')
    data=DataHandlers.NYUDataStructure(outPath,'test');
    extractImageSet(data,imageNames(1,~split),depthNames(1,~split),labels(:,:,~split),allNames,goodClasses,tmp_depthFolder);
    data.save();
end

function extractImageSet(output,imageNames,depthNames,labels,allNames,goodClasses,tmp_depthFolder)
    goodIndices=find(ismember(allNames,goodClasses));
    nImg=length(imageNames);
    subN=round(nImg/10);
    tmpCalib=cell(1,nImg);
    tmpObjects=cell(1,nImg);
    parfor i=1:nImg
        if mod(i,subN)==0
            disp(['analysing image ' num2str(i) '/' num2str(nImg)])
        end
        loaded=load(fullfile(tmp_depthFolder,depthNames{i}),'depth');
        tmpCalib{i}=[525 0 239.5;0 525 319.5;0 0 1];
        tmpObjects{i}=detectObjects(labels(:,:,i),...
            allNames,goodIndices,loaded.depth,tmpCalib{i});
    end
    for i=nImg:-1:1
        output.addImage(i,imageNames{i},depthNames{i},'',[480 640],tmpObjects{i},tmpCalib{i});
    end
end

function object=detectObjects(labels,allNames,goodIndices,depth,calib)
    goodLabels=ismember(labels,goodIndices);
    labels(~goodLabels)=0;
    instances=zeros(size(labels));
    currentIndex=1;
    lSize=size(labels);
    for i=1:lSize(1)
        for j=1:lSize(2)
            if labels(i,j)>0
                nx=max(i-1,1):min(i+1,lSize(1));
                ny=max(j-1,1):min(j+1,lSize(2));
                nInst=instances(nx,ny);
                nLabels=nInst(labels(nx,ny)==labels(i,j));
                nLabels=nLabels(nLabels~=0);
                if isempty(nLabels)
                    instances(i,j)=currentIndex;
                    instanceConnection(1,currentIndex)=currentIndex;
                    currentIndex=currentIndex+1;
                else
                    instances(i,j)=min(nLabels);
                    otherLabels=nLabels(nLabels~=instances(i,j));
                    for q=1:length(otherLabels)
                        instanceConnection(1,otherLabels(q))=instances(i,j);
                    end
                end
            end
        end
    end

    for i=1:length(instanceConnection)
        instanceConnection(i)=instanceConnection(instanceConnection(i));
    end
    compInstances=zeros(size(instanceConnection));
    uniInstances=unique(instanceConnection);
    compInstances(uniInstances)=1:length(uniInstances);
    compInstances=compInstances(instanceConnection);
    instances(instances>0)=compInstances(instances(instances>0));

    goodInstances=true(1,length(uniInstances));
    for o=length(uniInstances):-1:1
        mask=instances==o;
        myLabel=labels(mask==true);
        [row,col]=find(mask);
        tmp=[min(row) max(row);min(col) max(col)];
        px=[tmp(1,1) tmp(1,1) tmp(1,2) tmp(1,2)];
        py=[tmp(2,1) tmp(2,2) tmp(2,2) tmp(2,1)];
        object(o)=DataHandlers.Object3DStructure(allNames{myLabel(1)},px,py,depth,calib);
        if min(abs(tmp(:,1)-tmp(:,2)))<5
            goodInstances(o)=false;
        end
    end
    object=object(goodInstances);
end