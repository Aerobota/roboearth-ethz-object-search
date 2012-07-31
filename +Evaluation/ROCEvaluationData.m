classdef ROCEvaluationData<Evaluation.EvaluationData
    
    properties(SetAccess='protected')
        curves
    end
    
    methods
        function addData(obj,newData,dataName)
            obj.curves(end+1).tp=newData.tp;
            obj.curves(end).fp=newData.fp;
            obj.curves(end).pos=newData.pos;
            obj.curves(end).neg=newData.neg;
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
                tpRate(:,c)=sum(obj.curves(c).tp(:,classSubset),2)/sum(obj.curves(c).pos(1,classSubset));
                fpRate(:,c)=sum(obj.curves(c).fp(:,classSubset),2)/sum(obj.curves(c).neg(1,classSubset));
            end
            
            plot(obj.myAxes,fpRate,tpRate,'-')

            axis(obj.myAxes,[0 max(1,max(max(fpRate))) 0 1])
            legend(obj.myAxes,{obj.curves.name},'location','southeast')
            xlabel(obj.myAxes,'false positive rate')
            ylabel(obj.myAxes,'true positive rate')
        end
    end
end