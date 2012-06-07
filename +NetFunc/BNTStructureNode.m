classdef BNTStructureNode<NetFunc.Node
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        parents;
        nameAll;
        states;
    end
    
    methods
        function obj=BNTStructureNode(namePrefix,internalConnections,states)
            obj.nameAll=namePrefix;
            subNodeNames=fieldnames(states);
            for i=1:length(subNodeNames)
                obj.parents.([obj.nameAll subNodeNames{i}])=cell(0,1);
                obj.states.([obj.nameAll subNodeNames{i}])=states.(subNodeNames{i});
            end
            obj.addParent(namePrefix,internalConnections);
        end
        function connect(obj,parentPrefix,subNodeLinks)
            if ischar(parentPrefix)
                obj.addParent(parentPrefix,subNodeLinks);
            elseif iscellstr(parentPrefix)
                for i=1:length(parentPrefix)
                    obj.addParent(parentPrefix{i},subNodeLinks);
                end
            elseif isa(parentPrefix,'NetFunc.Node')
                obj.addParent(parentPrefix.getNodeName(),subNodeLinks);
            else
                error('BNTStructureNode:connect:wrongDataType','PARENTPREFIX can have data type char-array, cell of strings or Node-object');
            end
        end
        function parents=getParents(obj)
            parents=obj.parents;
        end
        function name=getNodeName(obj)
            name=obj.nameAll;
        end
        function names=getSubNodeNames(obj)
            names=fieldnames(obj.states);
        end
        function states=getSubNodeStates(obj)
            states=obj.states;
        end
    end
    methods(Access='protected')
        function addParent(obj,parentPrefix,subNodeLinks)
            myNames=fieldnames(subNodeLinks);
            if ~isempty(myNames)
                assert(all(isfield(obj.states,strcat(obj.nameAll,myNames))),'SUBNODELINKS contains identifiers that don''t exist in the child node');
                for i=1:length(myNames)
                    obj.parents.([obj.nameAll myNames{i}])=...
                        vertcat(obj.parents.([obj.nameAll myNames{i}]),strcat(parentPrefix,subNodeLinks.(myNames{i})));
                end
            end
        end
    end
%     methods(Static,Access='protected')
%         function prefix=checkPrefix(prefix)
%             if prefix(end)~='_'
%                 prefix=[prefix '_'];
%             end
%         end
%     end
end

