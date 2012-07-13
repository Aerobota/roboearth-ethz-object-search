classdef OccurrenceEvaluationData
    
    properties(SetAccess='protected')
        names
        tpRate
        fpRate
        precision
        precisionTPR
        precisionFPR
        issummed
        baseline
    end
    
    properties(Constant)
        dataStyle={'b*','r-'}
        dataLegend={'separate','summed'}
    end
    
    methods
        function obj=OccurrenceEvaluationData(names,truePos,falsePos,pos,neg,baseline)
            obj.issummed=1+(size(truePos,2)==1);
            obj.names=names;
            obj.tpRate=truePos./pos(ones(size(truePos,1),1),:);
            obj.fpRate=falsePos./neg(ones(size(falsePos,1),1),:);
            obj.precision=truePos./(truePos+falsePos);
            obj.precisionTPR=linspace(0,1,2);
            obj.precisionFPR=obj.precisionTPR*(sum(pos,2)/sum(neg,2));
            if nargin<6
                obj.baseline=[];
            else
                obj.baseline=baseline;
            end
        end
        
        function drawROC(obj,titleDescription)
            plot(obj.fpRate,obj.tpRate,obj.dataStyle{obj.issummed},...
                obj.baseline.fpRate,obj.baseline.tpRate,'g-',...
                obj.precisionFPR,obj.precisionTPR,'k--')

            axis([0 1 0 1])
            legend(obj.dataLegend{obj.issummed},'baseline','precision=0.5','location','southeast')
            xlabel('false positive rate')
            ylabel('true positive rate')
            title(titleDescription)
            
            if obj.issummed==1
                hold on
                text(obj.fpRate+0.01,obj.tpRate-0.01,obj.names,'color','b')
                hold off
            end
        end
        
        function drawPrecisionRecall(obj,titleDescription)
            plot(obj.tpRate,obj.precision,obj.dataStyle{obj.issummed},...
                obj.baseline.tpRate,obj.baseline.precision,'g-')

            axis([0 1 0 1])
            legend(obj.dataLegend{obj.issummed},'baseline','location','southeast')
            xlabel('recall')
            ylabel('precision')
            title(titleDescription)

            if obj.issummed==1
                hold on
                text(obj.tpRate+0.01,obj.precision-0.01,obj.names,'color','b')
                hold off
            end
        end
    end
end