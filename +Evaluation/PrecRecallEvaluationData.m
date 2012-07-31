classdef PrecRecallEvaluationData<Evaluation.EvaluationData
    %PRECRECALLEVALUATIONDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        curves
    end
    
    methods
        function addData(obj,newData,dataName)
            obj.curves(end+1).tp=newData.tp;
            obj.curves(end).fp=newData.fp;
            obj.curves(end).pos=newData.pos;
%             obj.curves(end).neg=newData.neg;
            obj.curves(end).name=dataName;
        end
    end
    methods(Access='protected')
        function drawImpl(obj,classSubset)
            assert(~isempty(obj.curves),'EvaluationData:noData','No data has been added yet.')
            
            if nargin<2
                classSubset=true(1,size(obj.curves(1).tp,2));
            end
            
            for c=length(obj.curves):-1:1
                tmpTp=sum(obj.curves(c).tp(:,classSubset),2);
                tmpFp=sum(obj.curves(c).fp(:,classSubset),2);
                tpRate(:,c)=tmpTp/sum(obj.curves(c).pos(1,classSubset));
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

