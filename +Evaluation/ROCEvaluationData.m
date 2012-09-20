classdef ROCEvaluationData<Evaluation.EvaluationData
    
    methods(Access='protected')
        function newCurve=addDataImpl(obj,newData,classSubset)
            if nargin<3
                classSubset=true(1,size(newData.tp,2));
            end
%             index=length(obj.curves)+1;
            newCurve.tp=newData.tp(:,classSubset);
            newCurve.fp=newData.fp(:,classSubset);
            newCurve.pos=newData.pos(:,classSubset);
            newCurve.neg=newData.neg(:,classSubset);
        end
        
        function drawImpl(obj)
            for c=length(obj.curves):-1:1
                tpRate(:,c)=sum(obj.curves(c).tp,2)/sum(obj.curves(c).pos);
                fpRate(:,c)=sum(obj.curves(c).fp,2)/sum(obj.curves(c).neg);
            end
            
            hold(obj.myAxes,'on')
            for c=1:length(obj.curves)
                plot(obj.myAxes,fpRate(:,c),tpRate(:,c),'Color',obj.curves(c).colour,'LineStyle',obj.curves(c).style)
            end
            hold(obj.myAxes,'off')

            axis(obj.myAxes,[0 max(1,min(max(fpRate,[],1),[],2)) 0 1])
            legend(obj.myAxes,{obj.curves.name},'location','southeast')
            xlabel(obj.myAxes,'false positive rate')
            ylabel(obj.myAxes,'true positive rate')
        end
    end
end