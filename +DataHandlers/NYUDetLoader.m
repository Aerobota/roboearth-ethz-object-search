classdef NYUDetLoader<DataHandlers.NYULoader
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        trainSet='detectionsTrain.mat'
        testSet='detectionsTest.mat'
    end
    
    methods
        function obj=NYUDetLoader(filePath)
            obj=obj@DataHandlers.NYULoader(filePath);
            if ~exist(fullfile(obj.path,obj.trainSet{2}),'file') ||...
                    ~exist(fullfile(obj.path,obj.testSet{2}),'file')
                warning('Detections are not extracted yet');
            end
        end
        function extractDetections(obj,groundTruthLoader,detector)
            data=obj.runDetector(groundTruthLoader.getData(groundTruthLoader.trainSet),...
                {groundTruthLoader.classes.name},...
                fullfile(groundTruthLoader.path,groundTruthLoader.imageFolder),...
                detector);
            data.save(fullfile(obj.path,obj.trainSet))
            
            data=obj.runDetector(groundTruthLoader.getData(groundTruthLoader.testSet),...
                {groundTruthLoader.classes.name},...
                fullfile(groundTruthLoader.path,groundTruthLoader.imageFolder),...
                detector);
            data.save(fullfile(obj.path,obj.testSet))
        end
    end
    methods(Access='protected')
        function data=runDetector(obj,data,path,detector)
            nData=length(data);
            parfor i=1:nData
                %if mod(i,round(nData/10))==0
                    disp(['detecting image ' num2str(i) '/' num2str(nData)])
                %end
%                 data(i).annotation.object=[];
%                 for c=1:length(classes)
%                     data(i).annotation.object=[data(i).annotation.object,...
%                         detector.detectClass(classes{c},...
%                         imread(fullfile(imgPath,data(i).annotation.folder,data(i).annotation.filename)))];
%                 end
                collectedObjects=[];
                for c=1:length(obj.classes)
                    tmpObjects=detector.detectClass(obj.classes{c},...
                        imread(fullfile(path,obj.imageFolder,data.getFolder(i),data.getFilename(i))));
                    tmpLoaded=load(fullfile(path,obj.depthFolder,data.getFolder(i),data.getDepthname(i)));
                    for o=1:length(tmpObjects)
                        collectedObjects=[collectedObjects,...
                            DataHandlers.Object3DStructure(tmpObjects(o).name,...
                            tmpObjects(o).score,tmpObjects(o).polygon.x,tmpObjects(o).polygon.y,...
                            tmpLoaded.depth,data.getCalib(i))];
                    end
                end
                
                data.setObject(collectedObjects,i);
            end
        end
    end
end