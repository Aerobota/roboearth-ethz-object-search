classdef PrecRecallEvaluationData<Evaluation.EvaluationData
    %PRECRECALLEVALUATIONDATA Generates precision recall curves
    %   This is a handler class that generates precision recall plots. This
    %   class extends Evaluation.EvaluationData and has no public methods
    %   of its own.
    %
    %See also EVALUATION.EVALUTIONDATA
    
    methods(Access='protected')
        function newCurve=addDataImpl(~,newData,classSubset)
            if nargin<3
                classSubset=true(1,size(newData.tp,2));
            end
            
            % save the selected statistics
            newCurve.tp=newData.tp(:,classSubset);
            newCurve.fp=newData.fp(:,classSubset);
            newCurve.pos=newData.pos(:,classSubset);
        end
        
        function drawImpl(obj)
            % For each curve compute precision and recall
            for c=length(obj.curves):-1:1
                tmpTp=sum(obj.curves(c).tp,2);
                tmpFp=sum(obj.curves(c).fp,2);
                tpRate(:,c)=tmpTp/sum(obj.curves(c).pos);
                precision(:,c)=tmpTp./(tmpTp+tmpFp+eps);
            end
            
            % plot
            hold(obj.myAxes,'on')
            for c=1:length(obj.curves)
                plot(obj.myAxes,tpRate(:,c),precision(:,c),'Color',obj.curves(c).colour,...
                    'LineStyle',obj.curves(c).style,'LineWidth',obj.lineWidth)
            end
            hold(obj.myAxes,'off')

            % Limit the axis as this is a well defined area
            axis(obj.myAxes,[0 1 0 1])
            % Add text
            legend(obj.myAxes,{obj.curves.name},'location','northeast')
            xlabel(obj.myAxes,'recall')
            ylabel(obj.myAxes,'precision')
        end
    end
end

