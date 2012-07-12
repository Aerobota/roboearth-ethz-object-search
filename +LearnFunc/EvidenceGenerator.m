classdef EvidenceGenerator<handle
    methods(Abstract)
        evidence=getEvidence(obj,data,varargin);
    end
%     methods(Static,Access='protected')
%         function name2ind=generateIndexLookup(names)
%             for i=1:length(names)
%                 name2ind.(genvarname(names{i}))=i;
%             end
%         end
%     end
end