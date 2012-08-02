classdef CostOptimalEvaluationData<Evaluation.EvaluationData
    %COSTOPTIMALEVALUATIONDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        baseline
    end
    
    methods
        function setBaseline(obj,newData,colour)
            obj.baseline.tp=newData.tp;
            obj.baseline.fp=newData.fp;
            obj.baseline.pos=newData.pos;
            obj.baseline.neg=newData.neg;
            obj.baseline.colour=colour;
        end
    end
    
    methods(Access='protected')
        function index=addDataImpl(obj,newData,classSubset)
            if nargin<3
                classSubset=true(1,size(newData.tp,2));
            end
            
            if ~isempty(obj.curves)
                warning('EvaluationData:tooMuchData',...
                    'CostOptimalEvaluationData can only display one dataset at the same time');
            end
            
            obj.curves.tp=newData.tp(:,classSubset);
            obj.curves.fp=newData.fp(:,classSubset);
            obj.curves.pos=newData.pos(:,classSubset);
            obj.curves.neg=newData.neg(:,classSubset);
            obj.curves.classNames=newData.names(classSubset);
            index=1;
        end
        
        function drawImpl(obj)
            tpRateBase=sum(obj.baseline.tp,2)/sum(obj.baseline.pos);
            fpRateBase=sum(obj.baseline.fp,2)/sum(obj.baseline.neg);
            
            tpRate=obj.curves.tp./obj.curves.pos;
            fpRate=obj.curves.fp./obj.curves.neg;
            
            plot(obj.myAxes,fpRate',tpRate','Marker','*','LineStyle','none','Color',obj.curves.colour)
            hold(obj.myAxes,'on')
            plot(obj.myAxes,fpRateBase,tpRateBase,'LineStyle','-','Color',obj.baseline.colour)
            text(fpRate+0.01,tpRate-0.01,obj.curves.classNames,'Color',obj.curves.colour,'Parent', obj.myAxes)
            hold(obj.myAxes,'off')

%             axis(obj.myAxes,[0 max(1,max(max(fpRate))) 0 1])
            legend(obj.myAxes,obj.curves.name,'baseline','location','southeast')
            xlabel(obj.myAxes,'false positive rate')
            ylabel(obj.myAxes,'true positive rate')
        end
    end
end

