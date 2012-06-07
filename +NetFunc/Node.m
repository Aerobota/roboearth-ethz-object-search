classdef Node<handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
%     properties
%         subNodeNames;
%     end
    
    methods(Abstract)
        %connect(obj,parentPrefix,subNodeLinks);
        parents=getParents(obj);
        name=getNodeName(obj);
        names=getSubNodeNames(obj);
        states=getSubNodeStates(obj);
    end
    
end

