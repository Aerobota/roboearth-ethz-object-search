classdef NaiveOccurrenceEvidenceGenerator<LearnFunc.OccurrenceEvidenceGenerator
    %NAIVEOCCURRENCEEVIDENCEGENERATOR Generates naive Bayes evidence
    %   This class is used to generate evidence that can be used to
    %   estimate the occurrence probability with the naive Bayes method.
    
    methods
        function obj=NaiveOccurrenceEvidenceGenerator(states)
            obj=obj@LearnFunc.OccurrenceEvidenceGenerator(states);
        end
        
        function out=getEvidence(obj,data,targetClasses,subsetIndices,mode)
            %OUT=GETEVIDENCE(OBJ,DATA,TARGETCLASSES,SUBSETINDICES,MODE)
            %   This method returns evidence about the state of objects.
            %   The method has two modes 'perImage' and 'all' and the
            %   output is different for both modes.
            %
            %DATA is a DataHandlers.DataStructure class instance that
            %   contains the occurrence data.
            %
            %TARGETCLASSES is an numeric or logical index vector that
            %   selects for which classes the output is to be computed.
            %
            %SUBSETINDICES is an numeric or logical index vector that
            %   selects from which scenes the output is to be computed.
            %
            %OUT
            %   'perImage': OUT is simply a feed through for GETCBINS that
            %       selects classes and image indices
            %
            %   'all': OUT is a sxsxc matrix where s is the number of
            %       possible occurrence states and c the number of classes.
            %       OUT(1,2,20) is the frequency of scenes where
            %       TARGETCLASS is in state 1 while class 20 is in state 2.
            if strcmpi(mode,'perImage')
                out=obj.getCBins(data);
                out=out(targetClasses,subsetIndices);
            elseif strcmpi(mode,'all') 
                assert(length(targetClasses)==1,'EvidenceGenerator:badInput',...
                    'In mode ''all'' the targetClasses argument must be a scalar')
                % Get the data
                cBins=obj.getCBins(data);
                out=zeros(length(obj.states),length(obj.states),length(data.getClassNames()));
                
                % Prepare for linear indexing
                k=[1;size(out,1);size(out,1)*size(out,2)];
                
                for s=subsetIndices
                    % Count the pairwise state occurrences
                    v=[cBins(targetClasses*ones(size(out,3),1),s) cBins(:,s) (0:size(out,3)-1)'];
                    linInd=v*k+1;
                    out(linInd)=out(linInd)+1;
                end
            else
                error('EvidenceGenerator:badInput','The mode argument has to be ''all'' or ''perImage''.');
            end
        end
        
        function result=calculateStatistics(obj,testData,occLearner,occEval)
            myNames=occLearner.getLearnedClasses();
            
            for i=length(myNames):-1:1
                % Get the indices for all classes
                searchIndicesSmall=testData.className2Index(myNames(i));
                searchIndicesLarge=testData.className2Index(occLearner.model.(myNames{i}).parents);
                
                % Get the evidence per scene
                evidenceAll=obj.getEvidence(testData,[searchIndicesSmall,searchIndicesLarge],1:length(testData),'perImage');
                % Get the states of the sought class
                evidenceSmall=evidenceAll(1,:);
                % Get the states of the observed classes
                evidenceLarge=evidenceAll(2:end,:);
                
                % Reduce the sought evidence to be absent/present
                evidenceSmall(evidenceSmall>1)=1;
                
                if ~isempty(evidenceLarge)
                    for c=size(evidenceLarge,1):-1:1
                        % Generate p(observed|sought)
                        factorCollection(:,c,:)=permute(occLearner.model.(myNames{i}).condProb(:,evidenceLarge(c,:)+1,c),[1 3 2]);
                    end
                else
                    factorCollection=ones([size(occLearner.model.(myNames{i}).margP,1) 1 length(evidenceSmall)]);
                end
                
                % p(sought|observed)=prod(p(observed_i|sought))*p(sought)
                decisionInput.condProb=squeeze(prod(factorCollection,2)).*...
                    occLearner.model.(myNames{i}).margP(:,ones(length(evidenceSmall),1));
                
                % Normalize
                decisionInput.condProb=decisionInput.condProb./repmat(sum(decisionInput.condProb,1),[2 1]);
                
                % Compute the decisions
                decision=occEval.decisionImpl(decisionInput);
                
                % Compute the error statistics
                result.tp(:,i)=sum(repmat(evidenceSmall,[size(decision,1) 1]).*(decision==2),2);
                result.fp(:,i)=sum(repmat(~evidenceSmall,[size(decision,1) 1]).*(decision==2),2);
                result.pos(1,i)=sum(evidenceSmall);
                result.neg(1,i)=length(evidenceSmall)-result.pos(1,i);
                
                % Also add the expected utility during training if
                % available
                if isfield(occLearner.model.(myNames{i}),'expectedUtility')
                    result.expectedUtility(1,i)=occLearner.model.(myNames{i}).expectedUtility;
                end
            end
        end
        
        function eu=calculateExpectedUtility(obj,data,targetClasses,decisionSubset,testSubset,valueMatrix)
            nClasses=length(data.getClassNames());
            % Compute the statistics on the decision subset
            decMargP=obj.reduceToBool(obj.getMarginalProbabilities(data,1:nClasses,decisionSubset));
            if ~isempty(targetClasses)
                decCondP=obj.reduceToBool(obj.getEvidence(data,targetClasses(1),decisionSubset,'all'));
                decCondP=decCondP./repmat(sum(decCondP,2)+eps,[1 size(decCondP,2)]);
            end
            
            % Find the optimal decision probability
            threshold=(valueMatrix(1,1)-valueMatrix(2,1))/(valueMatrix(1,1)+valueMatrix(2,2)-valueMatrix(2,1)-valueMatrix(1,2));
            
            % Get the states of the test data
            statesTest=obj.getEvidence(data,1:nClasses,testSubset,'perImage');
            
            for i=nClasses:-1:1
                if ~ismember(i,targetClasses)
                    if isempty(targetClasses)
                        % Nothing observed compute only marginal
                        % probabilities
                        tmpCondProb=decMargP(:,i*ones(size(statesTest,2),1));
                        tmpTargetState=statesTest(i,:);
                    else
                        % Compute the naive Bayes probability for the
                        % observed classes plus the current new class
                        currentClasses=[targetClasses(2:end) i];
                        for c=length(currentClasses):-1:1
                            factorCollection(:,c,:)=permute(decCondP(:,statesTest(currentClasses(c),:)+1,currentClasses(c)),[1 3 2]);
                        end
                        tmpCondProb=squeeze(prod(factorCollection,2)).*...
                        decMargP(:,targetClasses(1)*ones(size(statesTest,2),1));
                        tmpCondProb=tmpCondProb./repmat(sum(tmpCondProb,1),[2 1]);
                        tmpTargetState=statesTest(targetClasses(1),:);
                    end
                    
                    % Do the decisions
                    tmpTargetState=tmpTargetState>0;
                    decisions=tmpCondProb(2,:)>=threshold;
                    % Compute expected utility
                    eu(1,i)=obj.calculateExpectedUtilityFromProb(tmpTargetState,decisions,valueMatrix);
                end
            end
        end
        
        function [margP,condP]=calculateModelStatistics(obj,data,targetClasses,subset)
            margP=obj.reduceToBool(obj.getMarginalProbabilities(data,targetClasses(1),subset));
            condP=obj.reduceToBool(obj.getEvidence(data,targetClasses(1),subset,'all'));
            condP=condP(:,:,targetClasses(2:end));
            condP=condP./repmat(sum(condP,2)+eps,[1 size(condP,2)]);
        end
    end
    
    methods(Access='protected',Static)
        function eu=calculateExpectedUtilityFromProb(state,decision,valueMatrix)
            eu=mean(valueMatrix(decision+state*size(valueMatrix,1)+1));
        end
    end
end

