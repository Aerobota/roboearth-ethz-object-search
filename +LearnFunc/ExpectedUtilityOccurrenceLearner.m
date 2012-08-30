classdef ExpectedUtilityOccurrenceLearner<LearnFunc.OccurrenceLearner
    properties(SetAccess='protected')
        valueMatrix % valueMatrix=[trueNegativ falseNegativ;falsePositiv truePositiv]
        maxParents
    end
    
    properties(Constant) 
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
                EULast=EUBase(cs);
                currentIndices=cs;
                goodIndices=cs;
                while(length(currentIndices)-1<obj.maxParents)
                    EUNew=obj.computeExpectedUtilitySplitDataset(data,currentIndices,setIndices);
                    EUDiff=EUNew-EULast;
                    EUDiff(currentIndices)=0;
                    EUDiff(smallIndex)=0;
                    EUDiff(EUDiff<0.001)=0;
                    [maxVal,maxI]=max(EUDiff);
                    if maxVal>0
                        currentIndices(end+1)=maxI;
                        EULast=EUNew(maxI);
                        goodIndices=currentIndices;
                        disp([classes{cs} ' given ' classes{maxI} ' improvement: ' num2str(maxVal) ' total: ' num2str(EULast)]);
                    else
                        break;
                    end
                end
                if ~isempty(goodIndices)
                    obj.model.(classes{cs}).parents=classes(goodIndices(2:end));
                    
                    obj.model.(classes{cs}).expectedUtility=EULast;

                    [obj.model.(classes{cs}).margP,obj.model.(classes{cs}).condProb]=...
                        obj.evidenceGenerator.calculateModelStatistics(data,goodIndices,1:length(data));
                end
            end
        end
    end
    methods(Access='protected')
        function EUNew=computeExpectedUtilitySplitDataset(obj,data,currentIndices,setIndices)
            EUNew=[];
            for i=1:size(setIndices,1)
                EUNew(end+1,:)=obj.evidenceGenerator.calculateExpectedUtility(...
                    data,currentIndices,setIndices{i,1},setIndices{i,2},obj.valueMatrix);
                EUNew(end+1,:)=obj.evidenceGenerator.calculateExpectedUtility(...
                    data,currentIndices,setIndices{i,2},setIndices{i,1},obj.valueMatrix);
            end
            EUNew=median(EUNew,1);
        end
    end
    methods(Static)        
        function out=cleanBooleanCP(boolCP,boolMargP)
            out=boolCP;
            zeroIndexes=sum(out(:,:),1)==0;
            out(:,zeroIndexes)=boolMargP(:,ones(1,sum(zeroIndexes)));
        end
    end
end