classdef FirstNEvaluationData<Evaluation.EvaluationData
    %FIRSTNEVALUATIONDATA Plotting utility for search task
    %   This utility class draws and handles plots that show the success
    %   rate of finding an object compared to the number of locations that
    %   need to be searched.
    %
    %FIRSTNEVALUATIONDATA(MAXCANDIDATES,TYPE)
    %   MAXCANDIDATES tells the plotting utility how many candidates should
    %   be shown maximally.
    %   TYPE is a string which is 'line' or 'bar' controlling if the data
    %   should be plotted as a bar plot or a line plot.
    %
    %ADDDATA(OBJ,NEWDATA,...)
    %   NEWDATA is a struct with two fields:
    %   - nCandidates: nCandidates{c}(n,1) denotes how many candidate
    %   points have been searched for class 'c' at data point 'n'.
    %   - tp: tp{c}(n,1) denotes how many objects of class 'c' have been
    %   found at data point 'n'.
    %
    %   sum(tp{c}) is the number of scenes searched for class 'c'.
    
    properties(SetAccess='protected')
        maxCandidates
        type
    end
    
    methods
        function obj=FirstNEvaluationData(maxCandidates,type)
            obj.maxCandidates=maxCandidates;
            obj.type=type;
        end
    end
    
    methods(Access='protected')
        function newCurve=addDataImpl(~,newData,classSubset)
            if nargin<3
                classSubset=true(1,length(newData.tp));
            end
            newCurve.tp=newData.tp(classSubset);
            newCurve.nCandidates=newData.nCandidates(classSubset);
        end
        
        function drawImpl(obj)
            % Initialize matrices
            candidates=1:obj.maxCandidates;
            tpRate=zeros(length(candidates),length(obj.curves));
            
            % For every curve compute each data point
            for c=length(obj.curves):-1:1
                [tmpCandidates,myRates]=obj.getRates(c);
                myCandidates=tmpCandidates(tmpCandidates<=obj.maxCandidates);
                myRates=myRates(tmpCandidates<=obj.maxCandidates);
                tpRate(myCandidates,c)=myRates;
            end
            
            % For every empty data point take the same data as the last
            % data point
            for i=2:size(tpRate,1)
                tpRate(i,tpRate(i,:)==0)=tpRate(i-1,tpRate(i,:)==0);
            end
            
            % Plot either as bar or line plot
            if strcmpi(obj.type,'bar')==1
                bar(obj.myAxes,candidates,tpRate)
            elseif strcmpi(obj.type,'line')==1
                hold(obj.myAxes,'on')
                for c=1:length(obj.curves)
                    plot(obj.myAxes,candidates,tpRate(:,c),obj.curves(c).style,...
                        'Color',obj.curves(c).colour,'MarkerEdgeColor',obj.curves(c).colour,...
                        'MarkerFaceColor',obj.curves(c).colour);
                end
                hold(obj.myAxes,'off')
            end

            % Set axis to be nice
            axis(obj.myAxes,[0 obj.maxCandidates+1 0 1])
            set(obj.myAxes,'XTick',1:obj.maxCandidates)
            % Generate legend and axes labels
            legend(obj.myAxes,{obj.curves.name},'location','southeast')
            xlabel(obj.myAxes,'number of candidate locations')
            ylabel(obj.myAxes,'probability of finding at least one item')
        end
        
        function [nCandidates,tpRates]=getRates(obj,curveIndex)
            % Create an oredered list of data points if multiple classes
            % have the same data point add them up.
            
            % Initialize matrices
            nCandidates=[];
            myTP=zeros(0,1);
            % For every class
            for s=1:length(obj.curves(curveIndex).tp)
                % Search all data points that are already in the collection
                [tf,ind]=ismember(obj.curves(curveIndex).nCandidates{s},nCandidates);
                
                % This is only false if the input data doesn't contain any
                % data points
                if ~isempty(tf)
                    % Add my found objects to already existing data points
                    myTP(ind(tf),1)=myTP(ind(tf),1)+obj.curves(curveIndex).tp{s}(tf,1);
                
                    % Add my new data points
                    tmpCandidates=[nCandidates;obj.curves(curveIndex).nCandidates{s}(~tf,1)];
                    tmpTP=[myTP;obj.curves(curveIndex).tp{s}(~tf,1)];
                    
                    % Sort the new data points
                    [~,ind]=sort(tmpCandidates,'ascend');
                    nCandidates=tmpCandidates(ind,1);
                    myTP=tmpTP(ind,1);
                end
            end
            % Calculate the cummulative retrieval rate
            tpRates=cumsum(myTP)./sum(myTP);
        end
    end
end

