classdef CooccurrenceEvidenceGenerator<LearnFunc.OccurrenceEvidenceGenerator
    
    methods
        function obj=CooccurrenceEvidenceGenerator(states)
            obj=obj@LearnFunc.OccurrenceEvidenceGenerator(states);
        end
        
        function cop=getEvidence(obj,data,classes,targetClasses)
            nClasses=length(classes);
            cop=zeros([repmat(length(obj.states),[1 length(targetClasses)+1]) nClasses]);
            
            s=size(cop);
            k=cumprod([1 s(1:end-1)])';
            extender=repmat(1:length(targetClasses),[nClasses 1]);
            
            name2indAll=LearnFunc.EvidenceGenerator.generateIndexLookup(classes);

            nSamples=length(data);

            for s=1:nSamples
                objects={data.getObject(s).name}';
                counts=zeros(1,length(classes));
                for o=1:length(objects)
                    id=name2indAll.(objects{o});
                    counts(id)=counts(id)+1;
                end
                cBins=obj.getStateIndices(counts)-1;
                cBinsTarget=cBins(targetClasses);
                v=[cBinsTarget(extender) cBins (0:nClasses-1)'];
                linInd=1+v*k;
                cop(linInd)=cop(linInd)+1;
            end
        end
    end
end