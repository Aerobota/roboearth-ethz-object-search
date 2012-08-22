classdef FirstNEvaluationData<Evaluation.EvaluationData
    %FIRSTNEVALUATIONDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Access='protected')
        function index=addDataImpl(obj,newData,classSubset)
            if nargin<3
                classSubset=true(1,length(newData.tp));
            end
            index=length(obj.curves)+1;
            obj.curves(index).tp=newData.tp(classSubset);
            obj.curves(index).nCandidates=newData.nCandidates(classSubset);
        end
        
        function drawImpl(obj,maxCandidates,type)
            if nargin<3
                type='bar';
            end
            
            candidates=1:maxCandidates;
            tpRate=zeros(length(candidates),length(obj.curves));
            
            for c=length(obj.curves):-1:1
                [tmpCandidates,myRates]=obj.getRates(c);
                myCandidates=tmpCandidates(tmpCandidates<=maxCandidates);
                myRates=myRates(tmpCandidates<=maxCandidates);
                tpRate(myCandidates,c)=myRates;
            end
            
            for i=2:size(tpRate,1)
                tpRate(i,tpRate(i,:)==0)=tpRate(i-1,tpRate(i,:)==0);
            end
            
%             colormap(obj.myAxes,vertcat(obj.curves.colour))
            if strcmpi(type,'bar')==1
                bar(obj.myAxes,candidates,tpRate)
            elseif strcmpi(type,'line')==1
                hold(obj.myAxes,'on')
                for c=1:length(obj.curves)
                    plot(obj.myAxes,candidates,tpRate(:,c),obj.curves(c).style,...
                        'Color',obj.curves(c).colour,'MarkerEdgeColor',obj.curves(c).colour,...
                        'MarkerFaceColor',obj.curves(c).colour);
                end
                hold(obj.myAxes,'off')
            end

            axis(obj.myAxes,[0 maxCandidates+1 0 1])
            legend(obj.myAxes,{obj.curves.name},'location','southeast')
            xlabel(obj.myAxes,'number of candidate locations')
            ylabel(obj.myAxes,'probability of finding at least one item')
        end
        
        function [nCandidates,tpRates]=getRates(obj,curveIndex)
            nCandidates=[];
            myTP=zeros(0,1);
            for s=1:length(obj.curves(curveIndex).tp)
                [tf,ind]=ismember(obj.curves(curveIndex).nCandidates{s},nCandidates);
                
                if ~isempty(tf)
                    myTP(ind(tf),1)=myTP(ind(tf),1)+obj.curves(curveIndex).tp{s}(tf,1);
                
                    tmpCandidates=[nCandidates;obj.curves(curveIndex).nCandidates{s}(~tf,1)];
                    tmpTP=[myTP;obj.curves(curveIndex).tp{s}(~tf,1)];
                    [~,ind]=sort(tmpCandidates,'ascend');

                    nCandidates=tmpCandidates(ind,1);
                    myTP=tmpTP(ind,1);
                end
            end
            tpRates=cumsum(myTP)./sum(myTP);
        end
    end
end

