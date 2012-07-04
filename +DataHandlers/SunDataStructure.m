classdef SunDataStructure<DataHandlers.DataStructure
    %SUNDATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access='protected')
        datasetName
    end
    
    methods
        function obj=SunDataStructure(datasetName,preallocationSize)
            if nargin<2
                preallocationSize=0;
            end
            obj=obj@DataHandlers.DataStructure(preallocationSize);
            obj.datasetName=datasetName;
        end
        function load(obj,path)
            assert(exist(path,'file')>0,'DataStructure:fileNotFound',...
                'The file %s doesn''t exist.',path)
            loaded=load(path,obj.datasetName);
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
        function save(obj,path)
            [tmpDir,~,~]=fileparts(path);
            if ~exist(tmpDir,'dir')
                [~,~,~]=mkdir(tmpDir);
            end
            
            for i=length(obj.data):-1:1
                tmpStruct(1,i).annotation.filename=obj.getFilename(i);
                tmpStruct(1,i).annotation.folder=obj.getFolder(i);
                tmpStruct(1,i).annotation.imagesize=obj.getImagesize(i);
                for o=length(obj.getObject(i)):-1:1
                    tmpStruct(1,i).annotation.object(o).name=obj.getObject(i,o).name;
                    tmpStruct(1,i).annotation.object(o).confidence=obj.getObject(i,o).score;
                    tmpStruct(1,i).annotation.object(o).detection=obj.getObject(i,o).overlap>=0.5;
                    tmpStruct(1,i).annotation.object(o).polygon=obj.getObject(i,o).polygon;
                end
            end
            
            tmpData.(obj.datasetName)=tmpStruct;
            if ~exist(path,'file')
                save(path,'-struct','tmpData');
            else
                save(path,'-struct','tmpData','-append');
            end
        end
        
        function newObject=getSubset(obj,indexer)
            newObject=DataHandlers.SunDataStructure(obj.datasetName);
            newObject.data=obj.data(indexer);
        end
    end
end