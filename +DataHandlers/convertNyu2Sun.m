function convertNyu2Sun(inPath,outPath)
%CONVERTNYU2SUN Summary of this function goes here
%   Detailed explanation goes here

    inFile=fullfile(inPath,'nyu_depth_v2_labeled.mat');

    disp('extracting images')
    %imageNames=extractImages(inFile,outPath);
    imageNames=cell(1,1449);
    warning('image loading deactivated')
    
    disp('loading other data')
    data=load(inFile,'labels','depths','names');
    disp('splitting dataset')
    split=rand(size(data.labels,3),1)<0.5;
    disp('extracting good classes')
    classes=extractGoodClasses(data.labels,data.names,outPath);
    
    extractObjects(split,imageNames,data.labels,data.depths,data.names,classes,outPath)


end

function imageNames=extractImages(inFile,outPath)
    disp('loading image data')
    imageName='img_%05d.jpg';
    imageFolder=fullfile(outPath,'Images');
    if ~exist(imageFolder,'dir')
        [~,~,~]=mkdir(imageFolder);
    end
    data=load(inFile,'images');
    
    disp('saving images')
    imageNames=cell(1,size(data.images,4));
    for i=1:size(data.images,4)
        imageNames{i}=fullfile(imageFolder,sprintf(imageName,i));
        imwrite(data.images(:,:,:,i),imageNames{i});
    end
end

function names=extractGoodClasses(labels,names,outPath)
    counts=zeros(size(names));
    numbers=(1:length(names))';
    for i=1:size(labels,3)
        counts=counts+ismember(numbers,labels(:,:,i));
    end
    names=names(counts>100)';
    
    save(fullfile(outPath,'sun09_objectCategories.mat'),'names');
end

function extractObjects(split,imageNames,labels,depths,allNames,goodClasses,outPath)
    disp('extracting training set')
    Dtraining=extractImageSet(imageNames(1,split),labels(:,:,split),depths(:,:,split),allNames,goodClasses);
    disp('extracting test set')
    Dtest=extractImageSet(imageNames(1,~split),labels(:,:,~split),depths(:,:,~split),allNames,goodClasses);
    
    disp('saving ground truth data')
    save(fullfile(outPath,'sun09_groundTruth.mat'),'Dtraining','Dtest')
end

function im=extractImageSet(imageNames,labels,depths,allNames,goodClasses)
    goodIndices=find(ismember(allNames,goodClasses));
    warning('computing only one image')
    %for i=length(imageNames):-1:1
    i=1;
        im(1,i).annotation.filename=imageNames{i};
        im(1,i).annotation.folder='';
        im(1,i).annotation.imagesize.nrows=480;
        im(1,i).annotation.imagesize.ncols=640;
        im(1,i).annotation.object=detectObjects(labels(:,:,i),depths(:,:,i),allNames,goodIndices);
    %end
    im=DataHandlers.removeAliases(im);
end

function object=detectObjects(labels,depths,allNames,goodIndices)
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
                %nLabels=unique(nInst(labels(nx,ny)==labels(i,j)));
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
    disp(unique(instanceConnection));
    figure
    imshow(instances/max(max(instances)),'ColorMap',colormap('Jet'))
%     figure
%     imshow(labels/max(max(labels)),'ColorMap',colormap('Jet'))
%     disp(max(max(labels)))
%     disp(instanceConnection)
    object=[];
end