classdef PrecRecallEvaluationData<Evaluation.EvaluationData
    %PRECRECALLEVALUATIONDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function addData(obj,newData,dataName,classSubset)
            if nargin<4
                classSubset=true(1,size(newData.tp,2));
            end
            obj.curves(end+1).tp=newData.tp(:,classSubset);
            obj.curves(end).fp=newData.fp(:,classSubset);
            obj.curves(end).pos=newData.pos(:,classSubset);
            obj.curves(end).name=dataName;
        end
    end
    methods(Access='protected')
        function drawImpl(obj)
            for c=length(obj.curves):-1:1
                tmpTp=sum(obj.curves(c).tp,2);
                tmpFp=sum(obj.curves(c).fp,2);
                tpRate(:,c)=tmpTp/sum(obj.curves(c).pos);
                precision(:,c)=tmpTp./(tmpTp+tmpFp);
            end
            
            plot(obj.myAxes,tpRate,precision,'-')

            axis(obj.myAxes,[0 1 0 1])
            legend(obj.myAxes,{obj.curves.name},'location','northeast')
            xlabel(obj.myAxes,'recall')
            ylabel(obj.myAxes,'precision')
        end
    end
end

