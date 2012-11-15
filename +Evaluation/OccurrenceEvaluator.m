classdef OccurrenceEvaluator<Evaluation.Evaluator
    %OCCURRENCEEVALUATOR Master Class for Evaluating Occurrence Models
    %   This class implements the EVALUATE method from the abstract
    %   EVALUATOR class.
    %
    %See also EVALUATION.EVALUATOR
    
    properties(SetAccess='protected')
        evidenceGenerator
    end
    
    properties(Constant)
        thresholds=linspace(0,1,Evaluation.Evaluator.nThresh)';
    end
    
    methods
        function result=evaluate(obj,testData,occurrenceLearner)
            %RESULT=EVALUATE(OBJ,TESTDATA,OCCURRENCELEARNER)
            %   This method evaluates OCCURRENCELEARNER on the TESTDATA.
            %   The returned RESULT is structure that contains data to be
            %   consumed by the appropriate EVALUATION.EVALUATIONDATA.
            %
            %See also EVALUATION.EVALUATIONDATA
            
            % Compute for informed model
            result.conditioned=occurrenceLearner.evidenceGenerator.calculateStatistics(testData,occurrenceLearner,obj);
            % Compute for uninformed model
            result.baseline=obj.calculateStatisticsBaseline(testData,occurrenceLearner);
            
            % Save the names of the learned classes
            myNames=occurrenceLearner.getLearnedClasses();
            result.conditioned.names=myNames;
            result.baseline.names=myNames;
        end
    end
    
    methods(Abstract)
        %DECISIONS=DECISIONIMPL(OBJ,MYDEPENDENCIES)
        %   Abstract method that implements the decision process if an
        %   object is present or absent. This function is used in
        %   LearnFunc.OccurrenceEvidenceGenerator.calculateStatistics.
        %
        %See also LEARNFUNC.OCCURRENCEEVIDENCEGENERATOR.CALCULATESTATISTICS
        decisions=decisionImpl(obj,myDependencies)
    end
    
    methods(Access='protected')
        function result=calculateStatisticsBaseline(obj,testData,occLearner)
            % Get the names of the learned classes
            myNames=occLearner.getLearnedClasses();
            
            % For every class
            for i=length(myNames):-1:1
                % Get the class index
                searchIndices=testData.className2Index(myNames{i});
                
                % Generate a simple evidence generator and extract the
                % occurrence probability
                tmpEvidenceGenerator=LearnFunc.ConditionalOccurrenceEvidenceGenerator({'0','1+'});
                boolEvidence=tmpEvidenceGenerator.getEvidence(testData,searchIndices,1:length(testData),'single');
                
                % Decide if the class occurrs
                decisions=obj.decisionBaseline(occLearner.model.(myNames{i}).margP);

                % Compute the statistics
                neg=repmat(boolEvidence(1,:),[size(decisions,1) 1]);
                pos=repmat(boolEvidence(2,:),[size(decisions,1) 1]);
                
                result.tp(:,i)=sum(pos.*(decisions(:,:)==2),2);
                result.fp(:,i)=sum(neg.*(decisions(:,:)==2),2);
                result.pos(1,i)=sum(boolEvidence(2,:),2);
                result.neg(1,i)=sum(boolEvidence(1,:),2);
            end
        end
        function decisions=decisionBaseline(obj,margP)
            % For each threshold if the margP is larger or equal the
            % threshold we decide the class occurs
            decisions=ones(length(obj.thresholds),1);
            tmpCP=margP(2*ones(length(obj.thresholds),1),:);
            decisions(tmpCP>=obj.thresholds)=2;
        end
    end
end

