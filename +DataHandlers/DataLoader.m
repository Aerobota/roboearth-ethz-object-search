classdef DataLoader<handle
    %IMAGELOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    %% Properties
    properties(SetAccess='protected')
        classes
        path
    end
    properties(Abstract,Constant)
        trainSet
        testSet
        imageFolder
        catFileName
    end
    
    %% Public Methods
    methods
        function obj=DataLoader(filePath)
            assert(exist(filePath,'dir')>0,'DataLoader:DirectoryNotFound','The specified directory was not found');
            obj.path=filePath;
        end
        
        function names=getClassNames(obj)
            names={obj.classes.name};
        end
    end
    methods(Abstract)
        image=getData(obj,desiredSet);
    end
    methods(Access='protected',Sealed)
        function data=removeAliases(obj,data)
            alias.books='book';
            alias.bottles='bottle';
            alias.boxes='box';
            alias.cars='car';
            alias.rocks='stone';
            alias.rock='stone';
            alias.stones='stone';
            alias.pillow='cushion';
            alias.monitor='screen';
            
            data=obj.removeAliasesImpl(data,alias);
        end
        
        function classes=getClasses(obj)
            tmpPath=fullfile(obj.path,obj.catFileName);
            assert(exist(tmpPath,'file')==2,'The file %s is missing.',tmpPath);
            in=load(tmpPath);
            classes(length(in.names),1).name=in.names{end};
            for i=1:length(in.names)
                classes(i).name=in.names{i};
            end
        end
    end
    methods(Abstract,Access='protected')
        data=removeAliasesImpl(obj,data,alias);
    end
end

