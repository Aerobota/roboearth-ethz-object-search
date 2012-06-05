classdef BNTGraph<NetFunc.Graph
    %BNTGRAPH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        dag;
%         nodeNames;
%         nodeParents;
        nodes;
        solver;
        net;
    end
    
    methods
        function obj=BNTGraph()
            obj.nodeNames=cell(0,1);
        end
        function addNodeImpl(obj,node)
            %names=node.getSubNodeNames();
            %obj.nodeNames={obj.nodeNames(:) names(:)}';
            %obj.nodeParents=[obj.nodeParents;node.getParents()];
            newLinks=node.getParents();
            names=fieldnames(newLinks);
            assert(~any(isfield(obj.nodes,names)),'A node identifier is used multiple times');
            nodeStates=node.getSubNodeStates();
            currentIndex=length(fieldnames(obj.nodes));
            for i=1:length(names)
                obj.nodes.(names{i}).parents=newLinks.(names{i});
                obj.nodes.(names{i}).nodeStates=nodeStates.(names{i});
                currentIndex=currentIndex+1;
                obj.nodes.(names{i}).index=currentIndex;
            end
        end
        function compile(obj)
            obj.dag=zeros(length(obj.nodes),length(obj.nodes));
            nameList=fieldnames(obj.nodes);
            for i=1:length(nameList)
                cNode=obj.nodes.(nameList{i});
                for p=1:length(cNode.parents)
                    obj.dag(cNode.index,obj.nodes.(cNode.parents{i}).index)=1;
                end
            end
            obj.net=mk_bnet(obj.dag,CL.node_sizes);
            
        end
    end
    
end

