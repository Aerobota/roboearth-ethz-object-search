classdef ROCEvaluationData<Evaluation.EvaluationData
    %ROCEVALUATIONDATA Generates receiver operating characteristics curves
    %   This is a handler class that generates receiver operating
    %   characteristics plots. This class extends Evaluation.EvaluationData
    %   and has no public methods of its own.
    %
    %See also EVALUATION.EVALUTIONDATA
    
    methods(Access='protected')
        function newCurve=addDataImpl(obj,newData,classSubset)
            if nargin<3
                classSubset=true(1,size(newData.tp,2));
            end
            
            % Save selected data
            newCurve.tp=newData.tp(:,classSubset);
            newCurve.fp=newData.fp(:,classSubset);
            newCurve.pos=newData.pos(:,classSubset);
            newCurve.neg=newData.neg(:,classSubset);
        end
        
        function drawImpl(obj)
            % Compute tp and fp rates
            for c=length(obj.curves):-1:1
                tpRate(:,c)=sum(obj.curves(c).tp,2)/sum(obj.curves(c).pos);
                fpRate(:,c)=sum(obj.curves(c).fp,2)/sum(obj.curves(c).neg);
            end
            
            % Plot
            hold(obj.myAxes,'on')
            for c=1:length(obj.curves)
                plot(obj.myAxes,fpRate(:,c),tpRate(:,c),'Color',obj.curves(c).colour,...
                    'LineStyle',obj.curves(c).style,'LineWidth',obj.lineWidth)
            end
            hold(obj.myAxes,'off')

            % Do some cleaning of the plot
            axis(obj.myAxes,[0 max(1,min(max(fpRate,[],1),[],2)) 0 1])
            legend(obj.myAxes,{obj.curves.name},'location','southeast')
            xlabel(obj.myAxes,'false positive rate')
            ylabel(obj.myAxes,'true positive rate')
        end
    end
end