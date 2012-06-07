classdef BNTSimpleNode<NetFunc.Node
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        parents;
        name;
        states;
    end
    
    methods
        function obj=BNTSimpleNode(name,states)
            obj.name=name;
            obj.parents=cell(0,1);
            obj.states=states;
        end
        function connect(obj,parent)
            if ischar(parent) || iscellstr(parent)
                obj.parents=vertcat(obj.parents,parent);
            elseif isa(parent,'NetFunc.Node')%isobject(parent)
                obj.parents=vertcat(obj.parents,parent.getSubNodeNames());
            else
                error('BNTSimpleNode:connect:wrongDataType','PARENT can have data type char-array, cell of strings or Node-object');
            end
        end
        function parents=getParents(obj)
            parents.(obj.name)=obj.parents;
        end
        function name=getNodeName(obj)
            name=obj.name;
        end
        function names=getSubNodeNames(obj)
            names={obj.name};
        end
        function states=getSubNodeStates(obj)
            states.(obj.name)=obj.states;
        end
    end
end

