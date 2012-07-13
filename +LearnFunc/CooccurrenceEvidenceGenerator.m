classdef CooccurrenceEvidenceGenerator<LearnFunc.OccurrenceEvidenceGenerator
    properties(SetAccess='protected')
        dataBuffer
    end
    
    methods
        function obj=CooccurrenceEvidenceGenerator(states)
            obj=obj@LearnFunc.OccurrenceEvidenceGenerator(states);
            obj.dataBuffer=struct('dataHandle',{},'cBins',{});
        end
        
        function cop=getEvidence(obj,data,targetClasses,subsetIndices,mode)
            if strcmpi(mode,'all')
                getAllClasses=true;
            elseif strcmpi(mode,'single')
                getAllClasses=false;
            else
                error('EvidenceGenerator:badInput','The mode argument has to be ''all'' or ''single''.');
            end
            
            if getAllClasses
                nClasses=length(data.getClassNames());
                cop=zeros([repmat(length(obj.states),[1 length(targetClasses)+1]) nClasses]);
                extender=repmat(1:length(targetClasses),[nClasses 1]);
                s=size(cop);
            else
                if length(targetClasses)==1
                    cop=zeros(length(obj.states),1);
                    s=length(cop);
                else
                    cop=zeros(repmat(length(obj.states),[1 length(targetClasses)]));
                    s=size(cop);
                end
            end
            
            k=cumprod([1 s(1:end-1)])';
            
            bufferIndex=0;
            for i=1:length(obj.dataBuffer)
                if obj.dataBuffer(i).dataHandle==data
                    bufferIndex=i;
                end
            end
            
            if bufferIndex==0
                obj.dataBuffer(end+1).cBins=obj.bufferCBins(data);
                obj.dataBuffer(end).dataHandle=data;
                bufferIndex=length(obj.dataBuffer);
            end

            for s=subsetIndices
                if getAllClasses
                    cBins=obj.dataBuffer(bufferIndex).cBins(:,s);

                    cBinsTarget=cBins(targetClasses);
                    v=[cBinsTarget(extender) cBins (0:nClasses-1)'];
                else
                    v=obj.dataBuffer(bufferIndex).cBins(targetClasses,s)';
                end
                linInd=1+v*k;
                cop(linInd)=cop(linInd)+1;
            end
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
end