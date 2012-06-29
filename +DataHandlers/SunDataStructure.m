classdef SunDataStructure<DataHandlers.DataStructure
    %SUNDATASTRUCTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access='protected')
        data
    end
    
    methods
        function obj=SunDataStructure()
            obj.data=struct('filename',{},'depthname',{},'folder',{},...
                'imagesize',{},'object',{},'calib',{});
        end
        function addImage(obj,filename,depthname,folder,imagesize,object,calib)
            if nargin==2
                if isa(filename,'DataHandlers.SunDataStructure')
                    obj.data=[obj.data filename.data];
                else
                    error('SunDataStructure:wrongClass','Input must be a SunDataStructure')
                end
            end
            obj.data(1,end+1).filename=filename;
            obj.data(end).depthname=depthname;
            obj.data(end).folder=folder;
            obj.data(end).imagesize=imagesize;
            assert(isa(object,'DataHandlers.ObjectStructure'),'SunDataStructure:wrongClass',...
                'The object must be of ObjectStructure class.')
            obj.data(end).object=object;
            obj.data(end).calib=calib;
        end
        function load(obj,path)
            error('SunDataStructure:notImplemented','Method not implemented')
        end
        function save(obj,path)
            error('SunDataStructure:notImplemented','Method not implemented')
        end
    end
end

