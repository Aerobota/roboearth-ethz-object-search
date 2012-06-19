classdef CombinedDataLoader
    %COMBINEDDATALOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        data
        names
        namesFilePath
    end
    
    methods
        function obj=CombinedDataLoader(DataLoaders,namesFilePath)
            obj.namesFilePath=namesFilePath;
            obj.data=struct('annotation',{});
            obj.names=cell(1,0);
            for i=1:length(DataLoaders)
                disp(['loading ' DataLoaders{i}.path])
                [tmpData,tmpNames]=obj.cleanData(DataLoaders{i}.path,...
                    DataLoaders{i});
                obj.data=[obj.data tmpData];
                obj.names=[obj.names tmpNames];
            end
            disp('writing name files')
            obj.writeNamesFile();
        end
        function image=getImage(obj,name)
            image=obj.data(ismember(obj.names,name));
            if(size(image,2)~=1)
                image=image(1);
            end
        end
        function writeNamesFile(obj)
            fid=fopen(obj.namesFilePath,'wt');
            for i=1:length(obj.names)
                fprintf(fid,'%s\n',obj.names{i}); 
            end
            fclose(fid);
        end
    end
    methods(Static,Access='protected')
        function [data,names]=cleanData(path,DataLoader)
            data=DataHandlers.removeAliases(DataLoader.getData(DataLoader.trainSet));
            for i=length(data):-1:1
                data(i).annotation.completeImgPath=fullfile(path,DataLoader.imageFolder,...
                    data(i).annotation.folder,data(i).annotation.filename);
                names{i}=data(i).annotation.filename;
            end
        end
    end
end

