classdef EvaluationData<handle
    %EVALUATIONDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        myHandle=[]
        myAxes=[]
        myTitle=[]
        curves
    end
    
    methods(Abstract,Access='protected')
        currentIndex=addDataImpl(obj,newData,classSubset)
        drawImpl(obj,varargin)
    end
    
    methods
        function addData(obj,newData,dataName,colour,linestyle,classSubset)
            if nargin<6
                currentIndex=obj.addDataImpl(newData);
            else
                currentIndex=obj.addDataImpl(newData,classSubset);
            end
            
            obj.curves(currentIndex).name=dataName;
            obj.curves(currentIndex).colour=colour;
            obj.curves(currentIndex).style=linestyle;
        end
        
        function draw(obj,varargin)
            assert(~isempty(obj.curves),'EvaluationData:noData','No data has been added yet.')
            
            if ishghandle(obj.myHandle,'figure')
                close(obj.myHandle);
            end
            
            obj.myHandle=figure();
            obj.myAxes=axes('parent',obj.myHandle);
            
            obj.drawImpl(varargin{:});
            
            if ~isempty(obj.myTitle)
                title(obj.myAxes,obj.myTitle);
            end
        end
        
        function setTitle(obj,newTitle)
            obj.myTitle=newTitle;
            if ~isempty(obj.myAxes)
                title(obj.myAxes,newTitle);
            end
        end
        
        function delete(obj)
            if ishghandle(obj.myHandle,'figure')
                close(obj.myHandle);
            end
        end
    end
end

