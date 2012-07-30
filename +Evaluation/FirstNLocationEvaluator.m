classdef FirstNLocationEvaluator<Evaluation.LocationEvaluator
    %CANDIDATELOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
%         function obj=FirstNLocationEvaluator(analyseAllImages)
%             obj=obj@Evaluation.LocationEvaluator(analyseAllImages);
%         end
    end
    
    methods(Access='protected')
        function result=scoreClass(~,inRange,~)
            result=find(any(inRange,1),1);
%             
%             if size(inRange,1)>3
%                 keyboard
%             end
%             inRange=inRange&(cumsum(inRange,2)==1|inRange==0);
%             result.tp=sum(inRange,1);
%             result.pointProb=candidateProb;
% 
%             result.pos=size(inRange,1);
        end
        
        function result=combineResults(~,collectedResults,~)
            data=cat(1,collectedResults{:});
            result=histc(data,unique(data));
            result=cumsum(result)/sum(result);
            
            
%             for c=size(collectedResults,2):-1:1
%                 good=cellfun(@(x)~isempty(x),collectedResults(:,c));
%                 positive(1,c)=sum(cellfun(@(x)x.pos,collectedResults(good,c)),1);
%                 negative(1,c)=sum(good);
%                 
%                 tmpTP=cellfun(@(x)x.tp',collectedResults(good,c),'uniformoutput',false);
%                 truePos{1,c}=vertcat(tmpTP{:});
%                 tmpThresh=cellfun(@(x)x.pointProb',collectedResults(good,c),'uniformoutput',false);
%                 threshold{1,c}=vertcat(tmpThresh{:});
%             end
%             
%             tmpBaseline=Evaluation.EvaluationData(classesSmall,...
%                 [0;sum(positive,2)],[0;sum(negative,2)],sum(positive,2),sum(negative,2));
%             
%             for c=length(classesSmall):-1:1
%                 [pcTP(:,c),pcFP(:,c)]=obj.reduceEvidence(truePos{c},threshold{c});
%             end
%             result.perClass=Evaluation.EvaluationData(classesSmall,...
%                 pcTP,pcFP,positive,negative,tmpBaseline);
%             
%             [cumTP,cumFP]=obj.reduceEvidence(vertcat(truePos{:}),vertcat(threshold{:}));
%             
%             result.cummulative=Evaluation.EvaluationData(classesSmall,...
%                 cumTP,cumFP,sum(positive,2),sum(negative,2),tmpBaseline);
        end
        
%         function [tpSmall,fpSmall]=reduceEvidence(obj,tp,prob)
%             if ~isempty(tp)
%                 [~,permIndex]=sort(prob,'descend');
% 
%                 tpSort=tp(permIndex);
%                 tpSum=cumsum(tpSort);
%                 fpSum=cumsum(~tpSort);
% 
%                 selector=[true;(tpSort(2:end-1)>0 & tpSort(3:end)==0);true];
% 
%                 tp=tpSum(selector);
%                 fp=fpSum(selector);
% 
%                 tpSmall=tp(round(linspace(1,length(tp),obj.nThresh)));
%                 fpSmall=fp(round(linspace(1,length(fp),obj.nThresh)));
%             else
%                 tpSmall=zeros(obj.nThresh,1);
%                 fpSmall=zeros(obj.nThresh,1);
%             end
%         end
    end
end

