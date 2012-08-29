classdef stateBinsBuffer<handle
    %STATEBINSBUFFER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access='protected')
        dataBuffer
    end
    
    methods(Static)
        function cBins=getCBins(data,evidenceGenerator)
            persistent myInstance
            
            if isempty(myInstance)
                myInstance=DataHandlers.stateBinsBuffer();
            end
            
            % find the buffer belonging to the queried dataset
            bufferIndex=0;
            for i=1:length(myInstance.dataBuffer)
                if myInstance.dataBuffer(i).dataHandle==data
                    bufferIndex=i;
                end
            end
            
            % if the datset hasn't been found yet, buffer the state bins
            % indices
            if bufferIndex==0
                myInstance.dataBuffer(end+1).cBins=myInstance.bufferCBins(data,evidenceGenerator);
                myInstance.dataBuffer(end).dataHandle=data;
                bufferIndex=length(myInstance.dataBuffer);
            end
            
            cBins=myInstance.dataBuffer(bufferIndex).cBins;
        end
    end
    
    methods(Static,Access='protected')
        function obj=stateBinsBuffer()
            obj.dataBuffer=struct('dataHandle',{},'cBins',{});
        end
        function cBins=bufferCBins(data,evidenceGenerator)
            nClasses=length(data.getClassNames());
            cBins=zeros(nClasses,length(data));
            for s=1:length(data)
                objects={data.getObject(s).name}';
                counts=zeros(1,nClasses);
                for o=1:length(objects)
                    id=data.className2Index(objects{o});
                    counts(id)=counts(id)+1;
                end
                tmpCBins=evidenceGenerator.getStateIndices(counts)-1;

                cBins(:,s)=tmpCBins;
            end
        end
    end
    
end

