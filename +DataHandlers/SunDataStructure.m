classdef SunDataStructure<DataHandlers.DataStructure
    %SUNDATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
%     properties(Access='protected')
%         data
%     end
    
    methods
        function obj=SunDataStructure(preallocationSize)
            if nargin<1
                preallocationSize=0;
            end
            obj=obj@DataHandlers.DataStructure(preallocationSize);
%             tmpCell=cell(1,preallocationSize);
%             obj.data=struct('filename',tmpCell,'depthname',tmpCell,...
%                 'folder',tmpCell,'imagesize',tmpCell,'object',tmpCell,'calib',tmpCell);
        end
%         function addImage(obj,index,filename,depthname,folder,imagesize,object,calib)
%             assert(isa(object,'DataHandlers.ObjectStructure'),'SunDataStructure:wrongClass',...
%                 'The object must be of ObjectStructure class.')
%             obj.data(index).filename=filename;
%             obj.data(index).depthname=depthname;
%             obj.data(index).folder=folder;
%             obj.data(index).imagesize=imagesize;
%             obj.data(index).object=object;
%             obj.data(index).calib=calib;
%         end
        function load(obj,path)
            error('SunDataStructure:notImplemented','Method not implemented')
        end
        function save(obj,path)
            error('SunDataStructure:notImplemented','Method not implemented')
        end
    end
end