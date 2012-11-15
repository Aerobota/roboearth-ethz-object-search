classdef EvidenceGenerator<handle
    %EVIDENCEGENERATOR Abstract base class
    %   This base class exists only for structure. It defines the method
    %   getEvidence but doesn't place any restrictions on input or output
    %   arguments other than the first and second input arguments.
    methods(Abstract)
        evidence=getEvidence(obj,data,varargin);
    end
end