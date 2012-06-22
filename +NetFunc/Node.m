classdef Node<handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Abstract)
        parents=getParents(obj);
        name=getNodeName(obj);
        names=getSubNodeNames(obj);
        states=getSubNodeStates(obj);
    end
    
end

