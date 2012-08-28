classdef CooccurrenceEvidenceGenerator<LearnFunc.OccurrenceEvidenceGenerator
    methods
        function obj=CooccurrenceEvidenceGenerator(states)
            obj=obj@LearnFunc.OccurrenceEvidenceGenerator(states);
        end
        
        function cop=getEvidence(obj,data,targetClasses,subsetIndices,mode)
            if strcmpi(mode,'all')
                getAllClasses=true;
            elseif strcmpi(mode,'single')
                getAllClasses=false;
            else
                error('EvidenceGenerator:badInput','The mode argument has to be ''all'' or ''single''.');
            end
            
            % get state bin indices
            allCBins=obj.getCBins(data);
            
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

            for s=subsetIndices
                if getAllClasses
                    cBins=allCBins(:,s);

                    cBinsTarget=cBins(targetClasses);
                    v=[cBinsTarget(extender) cBins (0:nClasses-1)'];
                else
                    v=allCBins(targetClasses,s)';
                end
                linInd=1+v*k;
                cop(linInd)=cop(linInd)+1;
            end
        end
    end
end