classdef SunConverter<DataHandlers.SunLoader
    %SUNCONVERTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        targetPath
    end
    properties(Constant)
        scenesSmallDataset={'kitchen';'office'}
        trainSet=cell(1,0)
        testSet=cell(1,0)
    end
    
    methods
        function obj=SunConverter(sourcePath,targetPath)
            obj=obj@DataHandlers.SunLoader(sourcePath,cell(1,0));
            obj.targetPath=targetPath;
        end
        function extractSmallDataset(obj)
            obj.generateSmallDataSet(obj.path,obj.targetPath);
        end
    end
    
    methods(Access='protected')
        function generateSmallDataSet(obj,inpath,outpath)
%             scenes={'kitchen';'office'};

            ilgt=DataHandlers.SunGTLoader(inpath);
            ildet=DataHandlers.SunDetLoader(inpath);

            dataPacks=[[{ildet} ildet.trainSet];[{ilgt} ilgt.trainSet];...
                [{ildet} ildet.testSet];[{ilgt} ilgt.testSet]];

            output=cell(size(dataPacks,1),1);

            for i=1:size(dataPacks,1)
                output{i}=obj.getSceneData(obj.scenesSmallDataset,dataPacks{i,1},dataPacks(i,2:end));
                disp(['loaded ' dataPacks{i,2} ' ' dataPacks{i,3}])
                output{i}=obj.removeAliases(output{i});
            end

            classes={ilgt.classes(:).name};
            for i=1:round(size(dataPacks,1)/2)
                classes=obj.cleanClasses(output{2*i-1},output{2*i},classes);
            end
            disp('cleaned classes')

            for i=1:round(size(dataPacks,1)/2)
                [output{2*i-1},output{2*i}]=obj.cleanImages(output{2*i-1},output{2*i},classes);
            end
            disp('cleaned images')

            for i=1:size(dataPacks,1)
                obj.getImageFiles(output{i},inpath,outpath);
            end
            disp('copied image files')

            for i=1:size(dataPacks,1)
                output{i}=obj.cleanObjects(output{i},classes);
            end
            disp('cleaned objects')

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

            names={ilgt.classes(ismember({ilgt.classes(:).name},classes)).name};
            heights=[ilgt.classes(ismember({ilgt.classes(:).name},classes)).height];
            save(fullfile(outpath,ilgt.catFileName),'names','heights');
        end
    end
    methods(Access='protected',Static)
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

        function getImageFiles(data,inPath,outPath)
            for i=1:length(data)
                inImg=fullfile(inPath,DataHandlers.SunConverter.imageFolder,data(i).annotation.folder,data(i).annotation.filename);
                outDir=fullfile(outPath,DataHandlers.SunConverter.imageFolder,data(i).annotation.folder);
                outImg=fullfile(outDir,data(i).annotation.filename);
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
                data(i).annotation.object=data(i).annotation.object(ismember({data(i).annotation.object.name},classes));
            end
        end
    end
end

