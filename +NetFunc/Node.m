classdef Node<handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        subNodeNames;
    end
    
    methods(Abstract)
        parents=getParents(obj);
        names=getSubNodeNames(obj);
        states=getSubNodeStates(obj);
    end
    
end

