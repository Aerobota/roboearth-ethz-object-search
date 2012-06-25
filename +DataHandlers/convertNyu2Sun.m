function convertNyu2Sun(inPath,outPath)
%CONVERTNYU2SUN Summary of this function goes here
%   Detailed explanation goes here

    inFile=fullfile(inPath,'nyu_depth_v2_labeled.mat');
    
    imageFolder=fullfile(outPath,'image');
    depthFolder=fullfile(outPath,'depth');

    disp('extracting images')
    [imageNames,depthNames]=extractImages(inFile,imageFolder,depthFolder);
    
    disp('loading other data')
    data=load(inFile,'labels','names');
    data=DataHandlers.removeAliases(data);
    disp('splitting dataset')
    split=rand(size(data.labels,3),1)<0.5;
    disp('extracting good classes')
    classes=extractGoodClasses(data.labels,data.names,outPath);
    
    extractObjects(split,imageNames,depthNames,data.labels,data.names,classes,outPath,depthFolder)

end

function [imageNames,depthNames]=extractImages(inFile,imageFolder,depthFolder) %outPath)
    imageName='img_%05d.jpg';
    depthName='depth_%05d.mat';
    disp('loading image data')
    if ~exist(imageFolder,'dir')
        [~,~,~]=mkdir(imageFolder);
    end
    data=load(inFile,'images');
    
    disp('saving images')
    imageNames=cell(1,size(data.images,4));
    for i=1:size(data.images,4)
        imageNames{i}=sprintf(imageName,i);
        imwrite(data.images(:,:,:,i),fullfile(imageFolder,imageNames{i}));
    end
    
    clear('data')
    
    disp('loading depth data')
    if ~exist(depthFolder,'dir')
        [~,~,~]=mkdir(depthFolder);
    end
    data=load(inFile,'depths');
    
    disp('saving depth')
    depthNames=cell(1,size(data.depths,3));
    for i=1:size(data.depths,3)
        depthNames{i}=sprintf(depthName,i);
        depth=data.depths(:,:,i);
        save(fullfile(depthFolder,depthNames{i}),'depth')
    end
end

function names=extractGoodClasses(labels,names,outPath)
    counts=zeros(size(names));
    numbers=(1:length(names))';
    for i=1:size(labels,3)
        counts=counts+ismember(numbers,labels(:,:,i));
    end
    names=names(counts>100)';
    
    save(fullfile(outPath,'objectCategories.mat'),'names');
end

function extractObjects(split,imageNames,depthNames,labels,allNames,goodClasses,outPath,depthFolder)
    disp('extracting training set')
    Dtraining=extractImageSet(imageNames(1,split),depthNames(1,split),labels(:,:,split),allNames,goodClasses,depthFolder);
    save(fullfile(outPath,'groundTruthTrain.mat'),'Dtraining');
    clear('Dtraining');
    disp('extracting test set')
    Dtest=extractImageSet(imageNames(1,~split),depthNames(1,~split),labels(:,:,~split),allNames,goodClasses,depthFolder);
    save(fullfile(outPath,'groundTruthTest.mat'),'Dtest');
    clear('Dtest');
end

function im=extractImageSet(imageNames,depthNames,labels,allNames,goodClasses,depthFolder)
    goodIndices=find(ismember(allNames,goodClasses));
    nImg=length(imageNames);
    subN=round(nImg/10);
    im(1,nImg).annotation=struct;
    parfor i=1:nImg
        if mod(i,subN)==0
            disp(['analysing image ' num2str(i) '/' num2str(nImg)])
        end
        im(1,i).annotation.filename=imageNames{i};
        im(1,i).annotation.depthname=depthNames{i};
        im(1,i).annotation.folder='';
        im(1,i).annotation.imagesize.nrows=480;
        im(1,i).annotation.imagesize.ncols=640;
        im(1,i).annotation.object=detectObjects(labels(:,:,i),allNames,goodIndices);
        loaded=load(fullfile(depthFolder,depthNames{i}),'depth');
        im(1,i).annotation.calib=[525 0 319.5;0 525 239.5;0 0 1];
        im(1,i).annotation.object=DataHandlers.evaluateDepth(im(1,i).annotation.object,loaded.depth,im(1,i).annotation.calib);
    end
end

function object=detectObjects(labels,allNames,goodIndices)
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
        object(o).name=allNames{myLabel(1)};
        [row,col]=find(mask);
        tmp=[min(row) max(row);min(col) max(col)];
        object(o).polygon.x=[tmp(1,1) tmp(1,1) tmp(1,2) tmp(1,2)];
        object(o).polygon.y=[tmp(2,1) tmp(2,2) tmp(2,2) tmp(2,1)];
        if min(abs(tmp(:,1)-tmp(:,2)))<5
            goodInstances(o)=false;
        end
    end
    object=object(goodInstances);
end