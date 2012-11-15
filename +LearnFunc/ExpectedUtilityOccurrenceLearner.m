classdef ExpectedUtilityOccurrenceLearner<LearnFunc.OccurrenceLearner
    %EXPECTEDUTILITYOCCURRENCELEARNER Uses expected utility to select parents
    %   This class is used to find the optimal set of observed parents to
    %   predict the occurrence of an object using expected utility.
    %
    %OBJ=EXPECTEDUTILITYOCCURRENCELEARNER(EVIDENCEGENERATOR,VALUEMATRIX)
    %   EVIDENCEGENERATOR is used in the constructor of LearnFunc.Learner.
    %   VALUEMATRIX is a 2x2 matrix that denotes the scores of the outcomes
    %   of the boolean decision. The scores are arranged as following:
    %   VALUEMATRIX=[trueNegativ falseNegativ;falsePositiv truePositiv]
    %
    %OBJ=EXPECTEDUTILITYOCCURRENCELEARNER(...,MAXPARENTS)
    %   Limits the number of possible parents to MAXPARENTS. Without this
    %   option the default value of 10 is used.
    %
    %See also LEARNFUNC.LEARNER
    
    properties(SetAccess='protected')
        valueMatrix % valueMatrix=[trueNegativ falseNegativ;falsePositiv truePositiv]
        maxParents
    end
    
    properties(Constant)
        %Defines how many repetitions of 2-fold cross validation are
        %performed.
        nrSplits=10
        defaultMaxParents=10
    end
    
    methods
        function obj=ExpectedUtilityOccurrenceLearner(evidenceGenerator,valueMatrix,maxParents)
            obj=obj@LearnFunc.OccurrenceLearner(evidenceGenerator);
            
            obj.valueMatrix=valueMatrix;
            if nargin>=3
                obj.maxParents=maxParents;
            else
                obj.maxParents=obj.defaultMaxParents;
            end
        end
        
        function learn(obj,data)
            % get classes and indices of small classes
            classes=data.getClassNames();
            smallIndex=data.className2Index(data.getSmallClassNames());
            
            % generate dataset splits
            for i=obj.nrSplits:-1:1
                tmpIndices=randperm(length(data));
                setIndices{i,2}=tmpIndices(ceil(length(tmpIndices)/2)+1:end);
                setIndices{i,1}=tmpIndices(1:ceil(length(tmpIndices)/2));
            end
            
            % calculate the base expected utility for all classes
            EUBase=obj.computeExpectedUtilitySplitDataset(data,[],setIndices);
            
            % for every small class greedy search for best parents
            for cs=smallIndex
                % Set the expected utility without parents as starting
                % point
                EULast=EUBase(cs);
                currentIndices=cs;
                while(length(currentIndices)-1<obj.maxParents)
                    % Compute the expected utility for all classes given
                    % the currently observed classes plus the sought class
                    % (currentIndices)
                    EUNew=obj.computeExpectedUtilitySplitDataset(data,currentIndices,setIndices);
                    % Compute the gain in EU
                    EUDiff=EUNew-EULast;
                    % Remove all classes that are already observed
                    EUDiff(currentIndices)=0;
                    % Remove all classes that are not observable due to
                    % their size
                    EUDiff(smallIndex)=0;
                    % Remove all gains below a threshold
                    EUDiff(EUDiff<0.001)=0;
                    % Find the highest gain
                    [maxVal,maxI]=max(EUDiff);
                    % If it is positive
                    if maxVal>0
                        % Add to the observed variables
                        currentIndices(end+1)=maxI;
                        % Set the new EU as the current
                        EULast=EUNew(maxI);
                        % Generate some output
                        disp([classes{cs} ' given ' classes{maxI} ' improvement: ' num2str(maxVal) ' total: ' num2str(EULast)]);
                    else
                        % If no gain can be found break
                        break;
                    end
                end
                
                % Save the model
                obj.model.(classes{cs}).parents=classes(currentIndices(2:end));

                obj.model.(classes{cs}).expectedUtility=EULast;

                [obj.model.(classes{cs}).margP,obj.model.(classes{cs}).condProb]=...
                    obj.evidenceGenerator.calculateModelStatistics(data,currentIndices,1:length(data));
            end
        end
    end
    methods(Access='protected')
        function EUNew=computeExpectedUtilitySplitDataset(obj,data,currentIndices,setIndices)
            EUNew=[];
            % For every split do 2-fold cross validation
            for i=1:size(setIndices,1)
                EUNew(end+1,:)=obj.evidenceGenerator.calculateExpectedUtility(...
                    data,currentIndices,setIndices{i,1},setIndices{i,2},obj.valueMatrix);
                EUNew(end+1,:)=obj.evidenceGenerator.calculateExpectedUtility(...
                    data,currentIndices,setIndices{i,2},setIndices{i,1},obj.valueMatrix);
            end
            % Take the median of the computed costs as the final value
            EUNew=median(EUNew,1);
        end
    end
    methods(Static)        
        function out=cleanBooleanCP(boolCP,boolMargP)
            %OUT=CLEANBOOLEANCP(BOOLCP,BOOLMARGP)
            %   Removes all events that have no observations and inputs the
            %   marginal probability as a substitute.
            out=boolCP;
            zeroIndexes=sum(out(:,:),1)==0;
            out(:,zeroIndexes)=boolMargP(:,ones(1,sum(zeroIndexes)));
        end
    end
end