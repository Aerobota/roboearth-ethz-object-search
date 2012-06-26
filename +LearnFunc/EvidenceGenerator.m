classdef EvidenceGenerator
    methods(Abstract)
        evidence=getRelativeEvidence(image);
        evidence=getAbsoluteEvidence(image);
    end
end