classdef NYUConverter<DataHandlers.NYULoader
    %NYUCONVERTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        negativeDataLoader
        targetPath
    end
    properties(Constant)
        scenesNegativeDataset={'outdoor','road','street','mountain'};
        maxNum=600;
        trainSet={'groundTruthTrain.mat','Dtraining'}
        testSet={'groundTruthTest.mat','Dtest'}
    end
    
    methods
        function obj=NYUConverter(sourcePath,targetPath,negativeDataLoader)
            obj=obj@DataHandlers.NYULoader(sourcePath,cell(1,0));
            obj.negativeDataLoader=negativeDataLoader;
            obj.targetPath=targetPath;
        end
        
        function convertFromNyuDataset(obj)
            obj.convertNyu2Sun(obj.path,obj.targetPath);
            obj.generateNegativeDataSet(obj.negativeDataLoader,obj.targetPath);
        end
    end
    
    methods(Access='protected')
        function convertNyu2Sun(obj,inPath,outPath)
        %CONVERTNYU2SUN Summary of this function goes here
        %   Detailed explanation goes here

            inFile=fullfile(inPath,'nyu_depth_v2_labeled.mat');

            tmp_imageFolder=fullfile(outPath,obj.imageFolder);
            tmp_depthFolder=fullfile(outPath,obj.depthFolder);

            disp('extracting images')
            [imageNames,depthNames]=DataHandlers.NYUConverter.extractImages...
                (inFile,tmp_imageFolder,tmp_depthFolder);

            disp('loading other data')
            tmp_data=load(inFile,'labels','names');
            tmp_data=obj.removeAliases(tmp_data);
            disp('splitting dataset')
            split=rand(size(tmp_data.labels,3),1)<0.5;
            disp('extracting good classes')
            classes=DataHandlers.NYUConverter.extractGoodClasses(tmp_data.labels,tmp_data.names,outPath);

            DataHandlers.NYUConverter.extractObjects(split,imageNames,...
                depthNames,tmp_data.labels,tmp_data.names,classes,outPath,tmp_depthFolder)

        end
    end
    methods(Access='protected',Static)
        function [imageNames,depthNames]=extractImages(inFile,tmp_imageFolder,tmp_depthFolder) %outPath)
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
            save(fullfile(outPath,DataHandlers.NYUConverter.catFileName),'-struct','tmpSave');
        end

        function extractObjects(split,imageNames,depthNames,labels,allNames,goodClasses,outPath,tmp_depthFolder)
            disp('extracting training set')
            Dtraining=DataHandlers.NYUConverter.extractImageSet(imageNames(1,split),...
                depthNames(1,split),labels(:,:,split),allNames,goodClasses,tmp_depthFolder);
            save(fullfile(outPath,DataHandlers.NYUConverter.trainSet{1}),DataHandlers.NYUConverter.trainSet{2});
            clear(DataHandlers.NYUConverter.trainSet{2});
            disp('extracting test set')
            Dtest=DataHandlers.NYUConverter.extractImageSet(imageNames(1,~split),...
                depthNames(1,~split),labels(:,:,~split),allNames,goodClasses,tmp_depthFolder);
            save(fullfile(outPath,DataHandlers.NYUConverter.testSet{1}),DataHandlers.NYUConverter.testSet{2});
            clear(DataHandlers.NYUConverter.testSet{2});
        end

        function im=extractImageSet(imageNames,depthNames,labels,allNames,goodClasses,tmp_depthFolder)
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
                im(1,i).annotation.object=DataHandlers.NYUConverter.detectObjects(labels(:,:,i),allNames,goodIndices);
                loaded=load(fullfile(tmp_depthFolder,depthNames{i}),'depth');
                im(1,i).annotation.calib=[525 0 239.5;0 525 319.5;0 0 1];
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
        
        function generateNegativeDataSet(ilgt,outpath)

            dataPacks=[{ilgt} ilgt.trainSet];

            output=cell(size(dataPacks,1),1);

            for i=1:size(dataPacks,1)
                output{i}=DataHandlers.NYUConverter.getSceneData(...
                    DataHandlers.NYUConverter.scenesNegativeDataset,...
                    dataPacks{i,1},dataPacks(i,2:end),DataHandlers.NYUConverter.maxNum);
                disp(['loaded ' dataPacks{i,2} ' ' dataPacks{i,3}])
            end

            for i=1:size(dataPacks,1)
                DataHandlers.NYUConverter.getImageFiles(output{i},ilgt,outpath);
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

            [~,~,~]=copyfile(fullfile(ilgt.path,ilgt.catFileName),...
                fullfile(outpath,ilgt.catFileName));
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

        function getImageFiles(tmp_data,ilgt,outPath)
            for i=1:length(tmp_data)
                inImg=fullfile(ilgt.path,ilgt.imageFolder,tmp_data(i).annotation.folder,tmp_data(i).annotation.filename);
                outDir=fullfile(outPath,ilgt.imageFolder,tmp_data(i).annotation.folder);
                outImg=fullfile(outDir,tmp_data(i).annotation.filename);
                if ~exist(outImg,'file')
                    if ~exist(outDir,'dir')
                        [~,~,~]=mkdir(outDir);
                    end
                    [~,~,~]=copyfile(inImg,outImg);
                end
            end
        end
    end
end

