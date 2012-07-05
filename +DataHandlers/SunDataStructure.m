classdef SunDataStructure<DataHandlers.DataStructure
    %SUNDATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access='protected')
        datasetName
    end
    
    methods
        function obj=SunDataStructure(path,datasetName,preallocationSize)
            if nargin<3
                preallocationSize=0;
            end
            obj=obj@DataHandlers.DataStructure(path,preallocationSize);
            obj.datasetName=datasetName;
        end
        function load(obj)
            assert(exist(obj.filePath,'file')>0,'DataStructure:fileNotFound',...
                'The file %s doesn''t exist.',path)
            loaded=load(obj.filePath,obj.datasetName);
            tmpData=loaded.(obj.datasetName);
            hasScore=isfield(tmpData(1).annotation.object,'confidence');
            hasOverlap=isfield(tmpData(1).annotation.object,'detection');
            for i=length(tmpData):-1:1
                for o=length(tmpData(i).annotation.object):-1:1
                    if hasScore
                        tmpScore=tmpData(i).annotation.object(o).confidence;
                    else
                        tmpScore=[];
                    end
                    if hasOverlap
                        tmpOverlap=double(tmpData(i).annotation.object(o).detection);
                    else
                        tmpOverlap=1;
                    end
                    tmpObject(o)=DataHandlers.ObjectStructure(tmpData(i).annotation.object(o).name,...
                        tmpScore,tmpOverlap,tmpData(i).annotation.object(o).polygon.x,...
                        tmpData(i).annotation.object(o).polygon.y);
                end
                obj.addImage(i,tmpData(i).annotation.filename,'',tmpData(i).annotation.folder,...
                    tmpData(i).annotation.imagesize,tmpObject,[]);
            end
        end
        function save(obj)
            if ~exist(obj.dataPath,'dir')
                [~,~,~]=mkdir(obj.dataPath);
            end
            
            for i=length(obj.data):-1:1
                tmpStruct(1,i).annotation.filename=obj.getFilename(i);
                tmpStruct(1,i).annotation.folder=obj.getFolder(i);
                tmpStruct(1,i).annotation.imagesize=obj.getImagesize(i);
                tmpObjects=obj.getObject(i);
                for o=length(tmpObjects):-1:1
                    tmpStruct(1,i).annotation.object(o).name=tmpObjects(o).name;
                    tmpStruct(1,i).annotation.object(o).confidence=tmpObjects(o).score;
                    tmpStruct(1,i).annotation.object(o).detection=tmpObjects(o).overlap>=0.5;
                    tmpStruct(1,i).annotation.object(o).polygon=tmpObjects(o).polygon;
                end
            end
            
            tmpData.(obj.datasetName)=tmpStruct;
            if ~exist(obj.filePath,'file')
                save(obj.filePath,'-struct','tmpData');
            else
                save(obj.filePath,'-struct','tmpData','-append');
            end
        end
        
        function newObject=getSubset(obj,indexer)
            newObject=DataHandlers.SunDataStructure(obj.datasetName);
            newObject.data=obj.data(indexer);
        end
        
        function delete(obj)
            for i=1:length(obj.data)
                delete(fullfile(obj.dataPath,obj.data(i).objectPath));
            end
        end
    end
end