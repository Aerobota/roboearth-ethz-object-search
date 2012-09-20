classdef PrecRecallEvaluationData<Evaluation.EvaluationData
    %PRECRECALLEVALUATIONDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Access='protected')
        function newCurve=addDataImpl(~,newData,classSubset)
            if nargin<3
                classSubset=true(1,size(newData.tp,2));
            end
%             index=length(obj.curves)+1;
            newCurve.tp=newData.tp(:,classSubset);
            newCurve.fp=newData.fp(:,classSubset);
            newCurve.pos=newData.pos(:,classSubset);
        end
        
        function drawImpl(obj)
            for c=length(obj.curves):-1:1
                tmpTp=sum(obj.curves(c).tp,2);
                tmpFp=sum(obj.curves(c).fp,2);
                tpRate(:,c)=tmpTp/sum(obj.curves(c).pos);
                precision(:,c)=tmpTp./(tmpTp+tmpFp+eps);
            end
            
            hold(obj.myAxes,'on')
            for c=1:length(obj.curves)
                plot(obj.myAxes,tpRate(:,c),precision(:,c),'Color',obj.curves(c).colour,'LineStyle',obj.curves(c).style)
            end
            hold(obj.myAxes,'off')

            axis(obj.myAxes,[0 1 0 1])
            legend(obj.myAxes,{obj.curves.name},'location','northeast')
            xlabel(obj.myAxes,'recall')
            ylabel(obj.myAxes,'precision')
        end
    end
end

