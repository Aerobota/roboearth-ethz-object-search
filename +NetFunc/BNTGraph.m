classdef BNTGraph<NetFunc.Graph
    %BNTGRAPH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        dag;
        nodes;
        solver;
        net;
        myGraphs;
    end
    methods
        function obj=BNTGraph()
            obj=obj@NetFunc.Graph();
            obj.nodes=struct;
            obj.myGraphs=[];
        end
        
        function setCPD(obj,index,cpd)
            assert(obj.compiled,'BNTGraph:setCPD:uncompiled',...
                'Adding a CPD to an uncompiled network may lead to undefined behaviour.')
            obj.net.CPD{index}=cpd;
        end
        
        function close(obj)
            close(obj.myGraphs(ismember(obj.myGraphs,allchild(0))));
            obj.myGraphs=[];
        end
        
        function delete(obj)
            obj.close();
        end
    end
    methods(Access='protected')
        function addNodeImpl(obj,node)
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
            nameList=fieldnames(obj.nodes);
            obj.dag=zeros(length(nameList),length(nameList));
            nodeSizes=zeros(1,length(nameList));
            for i=1:length(nameList)
                cNode=obj.nodes.(nameList{i});
                for p=1:length(cNode.parents)
                    obj.dag(obj.nodes.(cNode.parents{p}).index,cNode.index)=1;
                end
                nodeSizes(i)=length(cNode.nodeStates);
            end
            obj.net=mk_bnet(obj.dag,nodeSizes);
        end
        
        function viewGraphImpl(obj,~)
            nodeNames=fieldnames(obj.nodes);
            before=allchild(0);
            biograph(obj.dag,nodeNames).view();
            after=allchild(0);
            obj.myGraphs=[obj.myGraphs;after(ismember(after,before)==0)];
        end
    end
end

