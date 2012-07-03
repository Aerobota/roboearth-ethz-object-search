classdef NYULoader<DataHandlers.DataLoader
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(SetAccess='protected')
        data
        names
    end
    
    properties(Constant)
        catFileName='objectCategories.mat';
        imageFolder='image'
        depthFolder='depth'
    end
    
    %% Interface Methods
    methods
        function obj=NYULoader(filePath,classes)
            obj=obj@DataHandlers.DataLoader(filePath);
            if nargin<2
                obj.classes=obj.getClasses();
            else
                obj.classes=classes;
            end
        end
        function out=getData(obj,desiredSet)
            tmpPath=fullfile(obj.path,desiredSet);
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            out=DataHandlers.NYUDataStructure();
            out.load(tmpPath);
        end
        function image=getDataByName(obj,name)
            assert(~isempty(obj.names),'To access data by name the dataset needs to be buffered')
            image=obj.data.getSubset(ismember(obj.names,name));
            assert(~isempty(image),'Image %s doesn''t exist in this dataset',name);
            if(size(image,2)~=1)
                image=image.getSubset(1);
            end
        end
        function bufferDataset(obj,desiredSet)
            obj.data=obj.getData(desiredSet);
            obj.extractFileNames;
        end
        function addData(obj,inData)
            obj.data=[obj.data inData];
            obj.extractFileNames;
        end
        function writeNameListFile(obj,nameListFile)
            fid=fopen(nameListFile,'wt');
            for n=1:length(obj.names)
                fprintf(fid,'%s\n',obj.names{n});
            end
            fclose(fid);            
        end
    end
    
    %% Protected Methods for Loading
    methods(Access='protected')
        function classes=getClasses(obj)
            tmpPath=fullfile(obj.path,obj.catFileName);
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath);
            classes(length(in.names),1).name=in.names{end};
            for i=1:length(in.names)
                classes(i).name=in.names{i};
            end
        end
        
        function extractFileNames(obj)
            for i=length(obj.data):-1:1
                obj.names{1,i}=obj.data.getFilename(i);
            end            
        end
    end
    
    %% Protected Methods for File Conversion
    methods(Access='protected')
        function tmp_data=removeAliasesImpl(~,tmp_data,alias)
            tmp_data.names=genvarname(tmp_data.names);
            relabel=(1:length(tmp_data.names))';
            myAlias=(1:length(tmp_data.names))';
            goodLabel=true(size(tmp_data.names));
            for i=1:length(tmp_data.names)
                if isfield(alias,tmp_data.names{i})
                    mem=ismember(tmp_data.names,alias.(tmp_data.names{i}));
                    if any(mem)
                        goodLabel(i)=false;
                        myAlias(i)=find(mem);
                    else
                        tmp_data.names{i}=alias.(tmp_data.names{i});
                    end
                end
                relabel(i)=sum(goodLabel(1:i));
            end
            tmp_data.names=tmp_data.names(goodLabel);
            for i=1:size(tmp_data.labels,3)
                tmpLabel=tmp_data.labels(:,:,i);
                tmpLabel(tmpLabel~=0)=relabel(myAlias(tmpLabel(tmpLabel~=0)));
                tmp_data.labels(:,:,i)=tmpLabel;
            end
        end
    end
end