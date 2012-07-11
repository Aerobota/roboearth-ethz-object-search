classdef CooccurrenceEvidenceGenerator<LearnFunc.OccurrenceEvidenceGenerator
    properties(SetAccess='protected')
        dataBuffer
    end
    
    methods
        function obj=CooccurrenceEvidenceGenerator(states)
            obj=obj@LearnFunc.OccurrenceEvidenceGenerator(states);
            obj.dataBuffer=struct('dataHandle',{},'cBins',{});
        end
        
        function cop=getEvidence(obj,data,classes,targetClasses,subsetIndices)
%             if nargin<5
%                 subsetIndices=1:length(data);
%             end
            
            nClasses=length(classes);
            cop=zeros([repmat(length(obj.states),[1 length(targetClasses)+1]) nClasses]);
            
            s=size(cop);
            k=cumprod([1 s(1:end-1)])';
            extender=repmat(1:length(targetClasses),[nClasses 1]);
            
            bufferIndex=0;
            for i=1:length(obj.dataBuffer)
                if obj.dataBuffer(i).dataHandle==data
                    bufferIndex=i;
                end
            end
            
            if bufferIndex==0
                obj.dataBuffer(end+1).cBins=obj.bufferCBins(data,classes);
                obj.dataBuffer(end).dataHandle=data;
                bufferIndex=length(obj.dataBuffer);
            end

            for s=subsetIndices
%                 if bufferIndex==0
%                     objects={data.getObject(s).name}';
%                     counts=zeros(1,length(classes));
%                     for o=1:length(objects)
%                         id=name2indAll.(objects{o});
%                         counts(id)=counts(id)+1;
%                     end
%                     cBins=obj.getStateIndices(counts)-1;
%                     
%                     obj.dataBuffer(end).cBins(:,s)=cBins;
%                 else
                    cBins=obj.dataBuffer(bufferIndex).cBins(:,s);
%                 end
                
                cBinsTarget=cBins(targetClasses);
                v=[cBinsTarget(extender) cBins (0:nClasses-1)'];
                linInd=1+v*k;
                cop(linInd)=cop(linInd)+1;
            end
        end
    end
    methods(Access='protected')
        function cBins=bufferCBins(obj,data,classes)
            cBins=zeros(length(classes),length(data));
            name2indAll=LearnFunc.EvidenceGenerator.generateIndexLookup(classes);
            for s=1:length(data)
                objects={data.getObject(s).name}';
                counts=zeros(1,length(classes));
                for o=1:length(objects)
                    id=name2indAll.(objects{o});
                    counts(id)=counts(id)+1;
                end
                tmpCBins=obj.getStateIndices(counts)-1;

                cBins(:,s)=tmpCBins;
            end
        end
    end
end