classdef OccurrenceEvidenceGenerator<LearnFunc.EvidenceGenerator
    %OCCURRENCEEVIDENCEGENERATOR Abstract occurrence evidence generator
    %   This class defines a number of abstract methods to compute
    %   probabilities and expected utilities. In addition it has support
    %   methods for decoding state information.
    %
    %OBJ=OCCURRENCEEVIDENCEGENERATOR(STATES)
    %   The constructor needs the cell string array STATES to initialise
    %   the comparer method. There are three possible strings:
    %
    %   'n': if there has to be exactly n occurrences to be true i.e. '0'
    %   'n-m': if the number of occurrences has to be between the
    %       boundaries including them e.g. '1-2'
    %   'n+': if the number of occurrences has or higher
    %
    %   It is recommended that all possible number of occurrences falls
    %   into at least one of the bins, otherwise the result is undefined.
    
    properties(SetAccess='protected')
        states;
        comparer;
    end
    
    properties(Constant)
        minSamples=10
    end
    
    methods(Abstract)
        %RESULT=CALCULATESTATISTICS(OBJ,TESTDATA,OCCLEARNER,OCCEVAL)
        %   This method allows to calculate the error statistics of
        %   deciding if an object is present or not.
        %
        %TESTDATA is a DataHandlers.DataStructure class instance that
        %   contains the occurrence data.
        %
        %OCCLEARNER is a LearnFunc.OccurrenceLearner that contains the
        %   learned model.
        %
        %OCCEVAL is a Evaluation.OccurrenceEvaluator that specifies the
        %   evaluation method.
        result=calculateStatistics(obj,testData,occLearner,occEval)
        
        %EU=CALCULATEEXPECTEDUTILITY(OBJ,DATA,TARGETCLASSES,DECISIONSUBSET,TESTSUBSET,VALUEMATRIX)
        %   This method is used to compute the expected utility for a
        %   certain VALUEMATRIX and DATA.
        %
        %DATA is a DataHandlers.DataStructure class instance that
        %   contains the occurrence data.
        %
        %TARGETCLASSES is an numeric or logical index vector that
        %   selects the child class plus the observed classes.
        %
        %DECISIONSUBSET is an numeric or logical index vector that selects from
        %   which scenes the optimal action is to be computed.
        %
        %TESTSUBSET is an numeric or logical index vector that selects from
        %   which scenes the expected utility is to be computed.
        %
        %VALUEMATRIX is a 2x2 matrix as specified in
        %   LearnFunc.ExpectedUtilityOccurrenceLearner.
        %
        %EU is a vector that contains the expected utilities of all
        %   classes.
        %
        %See also LEARNFUNC.EXPECTEDUTILITYOCCURRENCELEARNER
        eu=calculateExpectedUtility(obj,data,targetClasses,decisionSubset,testSubset,valueMatrix)
        
        %[MARGP,CONDP]=CALCULATEMODELSTATISTICS(OBJ,DATA,TARGETCLASSES,SUBSET)
        %   Returns the necessary statistics for the final model.
        %
        %DATA is a DataHandlers.DataStructure class instance that
        %   contains the occurrence data.
        %
        %TARGETCLASSES is an numeric or logical index vector that
        %   selects for which classes the probability is to be computed.
        %
        %SUBSET is an numeric or logical index vector that selects from
        %   which scenes the probability is to be computed.
        [margP,condP]=calculateModelStatistics(obj,data,targetClasses,subset)
    end
    
    methods
        function obj=OccurrenceEvidenceGenerator(states)
            obj.states=states;
            obj.comparer=obj.generateComparer(obj.states);
        end    
        
        function indices=getStateIndices(obj,counts)
            %INDICES=GETSTATEINDICES(OBJ,COUNTS)
            %   Returns the indices of the state bins for each occurrence
            %   count.
            %
            %COUNTS is a row vector where each element is the number of
            %   occurrences of an object class in a scene.
            %
            %INDICES is an index vector of the same size as COUNTS that
            %   indicates in which occurrence state bin each element belongs.
            assert(size(counts,1)==1,'PairwiseProbability:getStateIndices:matrixSize',...
                'Counts has to be a row vector.');

            indices=zeros(length(counts),1);
            for i=1:length(obj.comparer)
                indices(obj.comparer{i}(counts))=i;
            end
            
            assert(all(indices)>0,'Pairwise:Probability:getStateIndices:badComparer',...
                'The states of the pairwise probability comparer are not complete.');
        end
        
        function cBins=getCBins(obj,data)
            %CBINS=GETCBINS(OBJ,DATA)
            %   This function returns the state index for all object classes
            %   over all scenes. The process is buffered meaning that the first
            %   time this function is called with a set of data it takes
            %   long to return, while consecutive calls are very fast.
            %
            %DATA is a DataHandlers.DataStructure class instance that
            %   contains the occurrence data.
            %
            %CBINS is a cxs matrix where CBINS(i,j) is the state bin index
            %   of class i in scene j. Note that the indices are from 0.
            %   
            %   Example:
            %       oeg=OccurrenceEvidenceGenerator({'0','1+'});
            %       cBins=oeg.getCBins(data);
            %       
            %       The value cBins(3,6)==1 means that one or more
            %       instances of class 3 are present in scene 6.
            %       The value cBins(2,6)==0 means that no
            %       instances of class 2 are present in scene 6.
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
            
            % Return the correct buffer element
            cBins=dataBuffer(bufferIndex).cBins;
        end
        
        function margP=getMarginalProbabilities(obj,data,targetClasses,subset)
            %MARGP=GETMARGINALPROBABILITIES(OBJ,DATA,TARGETCLASSES,SUBSET)
            %   Returns the marginal occurrence probabilities of a subset
            %   of classes in a subset of images.
            %
            %DATA is a DataHandlers.DataStructure class instance that
            %   contains the occurrence data.
            %
            %TARGETCLASSES is an numeric or logical index vector that
            %   selects for which classes the probability is to be computed.
            %
            %SUBSET is an numeric or logical index vector that selects from
            %   which scenes the probability is to be computed.
            %
            %MARGP is a matrix statexc where each column is the marginal
            %   probability of one class.
            cBins=obj.getCBins(data);
            cBins=permute(cBins(targetClasses,subset),[3,1,2]);
            margP=sum(repmat((0:length(obj.states)-1)',size(cBins))==repmat(cBins,[length(obj.states),1]),3);
            margP=margP./repmat(sum(margP,1),[size(margP,1),1]);
        end
    end
    
    methods(Static)
        function bool=reduceToBool(in)
            %BOOL=REDUCETOBOOL(IN)
            %   Reduces the first dimension of IN to a size of two by
            %   summing up IN(2:end,:).
            tmpSize=size(in);
            bool=zeros([2 tmpSize(2:end)]);
            bool(1,:)=in(1,:);
            bool(2,:)=sum(in(2:end,:),1);
        end
    end
    
    methods(Access='protected')
        function cBins=bufferCBins(obj,data)
            % Generate the cBins
            nClasses=length(data.getClassNames());
            cBins=zeros(nClasses,length(data));
            % For each scene
            for s=1:length(data)
                % Get all object names
                objects={data.getObject(s).name}';
                counts=zeros(1,nClasses);
                for o=1:length(objects)
                    % Find the class index of the current object
                    id=data.className2Index(objects{o});
                    % Increment the count of the correct class
                    counts(id)=counts(id)+1;
                end
                % Get the state indices for all counts
                cBins(:,s)=obj.getStateIndices(counts)-1;
            end
        end
    end
    
    methods(Access='protected',Static)
        function comparer=generateComparer(states)
            % Parse the input state strings into anonymous comparer
            % functions.
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
            % Selects the correct value from the value matrix
            out=in((j-1)*size(in,1)+i);
        end
    end
end