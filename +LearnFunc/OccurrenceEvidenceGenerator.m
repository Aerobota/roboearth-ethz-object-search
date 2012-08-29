classdef OccurrenceEvidenceGenerator<LearnFunc.EvidenceGenerator
    properties(SetAccess='protected')
        states;
        comparer;
    end
    
    properties(Constant)
        minSamples=10
    end
    
    methods(Abstract)
        result=calculateStatistics(obj,testData,occLearner,occEval)
        eu=calculateExpectedUtility(obj,data,targetClasses,decisionSubset,testSubset,valueMatrix)
        [margP,condP]=calculateModelStatistics(obj,data,targetClasses)
    end
    
    methods
        function obj=OccurrenceEvidenceGenerator(states)
            obj.states=states;
            obj.comparer=obj.generateComparer(obj.states);
        end    
        
        function indices=getStateIndices(obj,counts)
            assert(size(counts,1)==1,'PairwiseProbability:getStateIndices:matrixSize',...
                'Counts has to be a row vector.');

            indices=zeros(length(counts),1);
            for i=1:length(obj.comparer)
                indices(obj.comparer{i}(counts))=i;
            end
            
            assert(length(indices)==length(counts),'Pairwise:Probability:getStateIndices:badComparer',...
                'The states of the pairwise probability comparer are not complete.');
        end
        
        function cBins=getCBins(obj,data)
            persistent dataBuffer
            
            if isempty(dataBuffer)
                dataBuffer=struct('dataHandle',{},'states',{},'cBins',{});
            end
            
            % find the buffer belonging to the queried dataset
            bufferIndex=0;
            for i=1:length(dataBuffer)
                if dataBuffer(i).dataHandle==data &&...
                        length(dataBuffer(i).states)==length(obj.states) &&...
                        all(strcmpi(dataBuffer(i).states,obj.states))
                    bufferIndex=i;
                end
            end
            
            % if the datset hasn't been found yet, buffer the state bins
            % indices
            if bufferIndex==0
                dataBuffer(end+1).cBins=obj.bufferCBins(data);
                dataBuffer(end).dataHandle=data;
                dataBuffer(end).states=obj.states;
                bufferIndex=length(dataBuffer);
            end
            
            cBins=dataBuffer(bufferIndex).cBins;
        end
    end
    
    methods(Access='protected')
        function cBins=bufferCBins(obj,data)
            nClasses=length(data.getClassNames());
            cBins=zeros(nClasses,length(data));
            for s=1:length(data)
                objects={data.getObject(s).name}';
                counts=zeros(1,nClasses);
                for o=1:length(objects)
                    id=data.className2Index(objects{o});
                    counts(id)=counts(id)+1;
                end
                tmpCBins=obj.getStateIndices(counts)-1;

                cBins(:,s)=tmpCBins;
            end
        end
    end
    
    methods(Access='protected',Static)
        function bool=reduceToBool(in)
            tmpSize=size(in);
            bool=zeros([2 tmpSize(2:end)]);
            bool(1,:)=in(1,:);
            bool(2,:)=sum(in(2:end,:),1);
        end
        
        function comparer=generateComparer(states)
            comparer=cell(length(states),1);
            lastMax=-1;
            
            for s=1:length(states)
                minMax=regexp(states{s},'-','split');
                if length(minMax)==2
                    % 'n-m' case
                    tmp(2,1)=str2double(minMax{2});
                    tmp(1,1)=str2double(minMax{1});
                    lowerBound=min(tmp);
                    upperBound=max(tmp);
                    comparer{s}=@(x) x>=lowerBound & x<=upperBound;
                    thisMin=min(tmp);
                    thisMax=max(tmp);
                else
                    nPlus=regexp(states{s},'+','split');
                    if length(nPlus)==2
                        % 'n+' case
                        lowerBound=str2double(nPlus{1});
                        comparer{s}=@(x) x>=lowerBound;
                        thisMin=nPlus{1};
                        thisMax=inf;
                    else
                        % 'n' case
                        equalValue=str2double(states{s});
                        comparer{s}=@(x) x==equalValue;
                        thisMin=str2double(states{s});
                        thisMax=thisMin;
                    end
                end
                assert(lastMax<thisMin,'PairwiseOccurrenceEvidenceGenerator:badStates',...
                    'The states must be monotonically increasing without overlap.')
                if s==1
                    assert(thisMax==0,'PairwiseOccurrenceEvidenceGenerator:badStates',...
                        'The first state has to be ''0''');
                end
            end
        end
        
        function out=selectVal(in,i,j)
            out=in((j-1)*size(in,1)+i);
        end
    end
end