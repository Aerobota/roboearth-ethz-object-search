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
        function obj=DataLoader(filePath,classes)
            assert(exist(filePath,'dir')>0,'DataLoader:DirectoryNotFound','The specified directory was not found');
            obj.path=filePath;
            if nargin<2
                obj.classes=obj.getClasses();
            else
                obj.classes=classes;
            end
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
    methods(Static)
        function overlap=computeOverlap(detObjects,gtObjects)
            overlap=zeros(size(detObjects));
            for gt=1:length(gtObjects)
                maxOverlap=0;
                maxIndex=0;
                gtBB=[min(gtObjects(gt).polygon.x) max(gtObjects(gt).polygon.x);...
                    min(gtObjects(gt).polygon.y) max(gtObjects(gt).polygon.y)];
                for det=1:length(detObjects)
                    if strcmpi(detObjects(det).name,gtObjects(gt).name)
                        detBB=[min(detObjects(det).polygon.x) max(detObjects(det).polygon.x);...
                            min(detObjects(det).polygon.y) max(detObjects(det).polygon.y)];
                        unionArea=max(min(gtBB(1,2),detBB(1,2))-max(gtBB(1,1),detBB(1,1)),0)*...
                            max(min(gtBB(2,2),detBB(2,2))-max(gtBB(2,1),detBB(2,1)),0);
                        tmpOverlap=unionArea/((gtBB(1,2)-gtBB(1,1))*(gtBB(2,2)-gtBB(2,1))+...
                            (detBB(1,2)-detBB(1,1))*(detBB(2,2)-detBB(2,1))-unionArea);
                        
                        if maxOverlap<tmpOverlap
                            maxOverlap=tmpOverlap;
                            maxIndex=det;
                        end
                    end
                end
                if maxIndex>0
                    overlap(maxIndex)=maxOverlap;
                end
            end
        end
    end
end

