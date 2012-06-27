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
    end
    
    %% Public Methods
    methods
        function obj=DataLoader(filePath)
%             assert(exist(filePath,'dir')>0,'DataLoader:DirectoryNotFound','The specified directory was not found');
            obj.path=filePath;
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
    end
    methods(Abstract,Access='protected')
        data=removeAliasesImpl(obj,data,alias);
    end
end

