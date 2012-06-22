classdef BNTSimpleNode<NetFunc.BNTStructureNode
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=BNTSimpleNode(name,states)
            intConn=struct;
            newStates.node=states;
            obj=obj@NetFunc.BNTStructureNode(name,intConn,newStates);
        end
    end
end