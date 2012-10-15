classdef EvaluationData<handle
    %EVALUATIONDATA Handles result data and plots
    %   This is the base class for any result plotting utility class. It
    %   supplies an interface for adding curves to a graph with ADDDATA and
    %   plotting the graphs with DRAW. The generated plot is handled by the
    %   class such that if the class is cleared, the plot is closed as
    %   well.
    %
    %   Any class inheriting from EVALUATIONDATA must implement ADDDATAIMPL
    %   and DRAWIMPL. An example implementation can be found in
    %   FIRSTNEVALUATIONDATA.
    %
    %   See also EVALUATION.FIRSTNEVALUATIONDATA.
    
    properties(Constant)
        lineWidth=2;
    end
    
    properties(SetAccess='protected')
        myHandle=[]
        myAxes=[]
        myTitle=[]
        curves=struct([])
    end
    
    methods(Abstract,Access='protected')
        newCurve=addDataImpl(obj,newData,classSubset)
        drawImpl(obj)
    end
    
    methods
        function addData(obj,newData,dataName,colour,linestyle,classSubset)
            %ADDDATA(OBJ,NEWDATA,DATANAME,COLOUR,LINESTYLE)
            %   This method adds the data in NEWDATA as a new curve to OBJ.
            %   NEWDATA is a struct with fields that depend on the
            %   implementation of the derived class. See ADDDATAIMPL.
            %   DATANAME is a string that will be displayed in the legend.
            %   COLOUR is any format of matlabs 'ColorSpec'.
            %   LINESTYLE is a character from the 'Line Property' 'LineStyle'.
            %
            %ADDDATA(...,CLASSSUBSET)
            %   CLASSSUBSET is either a numeric or logical indexer of the
            %   classes in the input data. Only indexed classes will be used
            %   to generate the plot. If omitted all classes are selected.
            
            % Apply default for classSubset and run addDataImpl
            if nargin<6
                newCurve=obj.addDataImpl(newData);
            else
                newCurve=obj.addDataImpl(newData,classSubset);
            end
            
            % Add the newCurve to the end of curves
            currentIndex=length(obj.curves)+1;
            tmpNames=fieldnames(newCurve);
            for n=1:length(tmpNames)
                obj.curves(currentIndex).(tmpNames{n})=newCurve.(tmpNames{n});
            end
            
            % Add the common properties to the curve
            obj.curves(currentIndex).name=dataName;
            obj.curves(currentIndex).colour=colour;
            obj.curves(currentIndex).style=linestyle;
        end
        
        function draw(obj)
            %DRAW(OBJ)
            %   Creates a figure and draws all data collected up until now.
            %   To update the figure just call DRAW again.
            assert(~isempty(obj.curves),'EvaluationData:noData','No data has been added yet.')
            
            % Check if I already posses a figure and close it
            if ishghandle(obj.myHandle,'figure')
                close(obj.myHandle);
            end
            
            % Create a new figure and get the axis handle
            obj.myHandle=figure();
            obj.myAxes=axes('parent',obj.myHandle);
            
            % Run the derived classes draw commands
            obj.drawImpl();
            
            % Add the title to the figure if there is a title
            if ~isempty(obj.myTitle)
                title(obj.myAxes,obj.myTitle);
            end
        end
        
        function setTitle(obj,newTitle)
            %SETTITLE(OBJ,NEWTITLE)
            %   This command sets the title of the current and all future
            %   figures owned by OBJ to NEWTITLE.
            
            % Save the newTitle
            obj.myTitle=newTitle;
            % Apply it to currently owned figure if it exists
            if ~isempty(obj.myAxes)
                title(obj.myAxes,newTitle);
            end
        end
        
        function delete(obj)
            %DELETE(OBJ)
            %   This method ensures that the owned figure is closed upon
            %   clearing the OBJ.
            if ishghandle(obj.myHandle,'figure')
                close(obj.myHandle);
            end
        end
    end
end

