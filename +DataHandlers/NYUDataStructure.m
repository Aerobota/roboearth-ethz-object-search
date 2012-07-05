classdef NYUDataStructure<DataHandlers.DataStructure
    %NYUDATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant)
        imageFolder='image'
        catFileName='objectCategories.mat'
        trainSet='Train'
        testSet='Test'
        gt='groundTruth'
        det='detections'
    end
    
    methods
        function obj=NYUDataStructure(path,testOrTrain,gtOrDet,preallocationSize)
            if nargin<4
                preallocationSize=0;
            end
            obj=obj@DataHandlers.DataStructure(path,testOrTrain,gtOrDet,preallocationSize);
        end
        function load(obj)
            filePath=fullfile(obj.path,[obj.storageName '.mat']);
            assert(exist(filePath,'file')>0,'DataStructure:fileNotFound',...
                'The file %s doesn''t exist.',obj.filePath)
            loaded=load(filePath);
            obj.data=loaded.data;
        end
        function save(obj)
            filePath=fullfile(obj.path,[obj.storageName '.mat']);
            if ~exist(obj.path,'dir')
                [~,~,~]=mkdir(obj.path);
            end
            tmpObj.data=obj.data;
            save(filePath,'-struct','tmpObj');
        end
        function newObject=getSubset(obj,indexer)
            newObject=DataHandlers.NYUDataStructure(obj.path,obj.setChooser{1},obj.setChooser{2});
            newObject.data=obj.data(indexer);
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
        
        function name=getStorageName(obj)
            name=[obj.setChooser{2} obj.setChooser{1}];
        end
    end
end