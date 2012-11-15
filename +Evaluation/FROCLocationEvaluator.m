classdef FROCLocationEvaluator<Evaluation.LocationEvaluationMethod
    %FROCLOCATIONEVALUATOR Free-Response Receiver Operating Characteristic
    %   This can be used to gather the information used to plot free-response
    %   receiver operating characteristics results. This is a
    %   LOCATIONEVALUATIONMETHOD and is used in conjunction with the
    %   LOCATIONEVALUATOR.
    %
    %   See also EVALUATION.LOCATIONEVALUATOR.
    
    properties(Constant)
        designation='FROC'
    end
    
    methods
        function result=scoreClass(~,inRange,candidateProb)
            % Only the first detections are true detections
            inRange=inRange&(cumsum(inRange,2)==1|inRange==0);
            % Save the number of true positives
            result.tp=sum(inRange,1);
            % Save the probability of the candidate points
            result.pointProb=candidateProb;
            % Save the number of ground-truth sought objects
            result.pos=size(inRange,1);
        end
        
        function result=combineResults(obj,collectedResults,classesSmall)
            for c=size(collectedResults,2):-1:1
                % Get all cells that have the sought object class
                good=cellfun(@(x)~isempty(x),collectedResults(:,c));
                % Get the number of sought instances
                positive(1,c)=sum(cellfun(@(x)x.pos,collectedResults(good,c)),1);
                % Get the number of sought images
                negative(1,c)=sum(good);
                % Get the true positives and the probabilities out of the
                % cell array
                tmpTP=cellfun(@(x)x.tp',collectedResults(good,c),'uniformoutput',false);
                truePos{1,c}=vertcat(tmpTP{:});
                tmpThresh=cellfun(@(x)x.pointProb',collectedResults(good,c),'uniformoutput',false);
                threshold{1,c}=vertcat(tmpThresh{:});
            end
            
            for c=length(classesSmall):-1:1
                [result.tp(:,c),result.fp(:,c)]=obj.reduceEvidence(truePos{c},threshold{c});
            end
            
            result.pos=positive;
            result.neg=negative;
            result.names=classesSmall;
        end
    end
    methods(Access='protected')
        function [tpSmall,fpSmall]=reduceEvidence(obj,tp,prob)
            if ~isempty(tp)
                % Sort all candidates in order of descending probability
                [~,permIndex]=sort(prob,'descend');
                tpSort=tp(permIndex);
                
                % Cumsum the boolean values to get the cummulative number
                % of tp and fp
                tpSum=cumsum(tpSort);
                fpSum=cumsum(~tpSort);

                % Only select points where there is a tp and the next is a
                % fp
                selector=[true;(tpSort(2:end-1)>0 & tpSort(3:end)==0);true];

                tp=tpSum(selector);
                fp=fpSum(selector);
                
                % Subsample the data to have nThresh data points
                tpSmall=tp(round(linspace(1,length(tp),obj.nThresh)));
                fpSmall=fp(round(linspace(1,length(fp),obj.nThresh)));
            else
                tpSmall=zeros(obj.nThresh,1);
                fpSmall=zeros(obj.nThresh,1);
            end
        end
    end
    
end

