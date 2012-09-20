classdef FROCLocationEvaluator<Evaluation.LocationEvaluationMethod
    %CANDIDATELOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        designation='FROC'
    end
    
    methods
        function result=scoreClass(~,inRange,candidateProb)
            inRange=inRange&(cumsum(inRange,2)==1|inRange==0);
            result.tp=sum(inRange,1);
            result.pointProb=candidateProb;

            result.pos=size(inRange,1);
        end
        
        function result=combineResults(obj,collectedResults,classesSmall)
            for c=size(collectedResults,2):-1:1
                good=cellfun(@(x)~isempty(x),collectedResults(:,c));
                positive(1,c)=sum(cellfun(@(x)x.pos,collectedResults(good,c)),1);
                negative(1,c)=sum(good);
                
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
                [~,permIndex]=sort(prob,'descend');

                tpSort=tp(permIndex);
                tpSum=cumsum(tpSort);
                fpSum=cumsum(~tpSort);

                selector=[true;(tpSort(2:end-1)>0 & tpSort(3:end)==0);true];

                tp=tpSum(selector);
                fp=fpSum(selector);

                tpSmall=tp(round(linspace(1,length(tp),obj.nThresh)));
                fpSmall=fp(round(linspace(1,length(fp),obj.nThresh)));
            else
                tpSmall=zeros(obj.nThresh,1);
                fpSmall=zeros(obj.nThresh,1);
            end
        end
    end
    
end

