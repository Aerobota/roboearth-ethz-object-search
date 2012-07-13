classdef EvidenceGenerator<handle
    methods(Abstract)
        evidence=getEvidence(obj,data,varargin);
    end
end