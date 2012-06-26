classdef OccurrenceLearner<handle
    %OCCURENCELEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract)
        dependencies=learnStructure(obj,data)
    end
    methods(Access='protected',Static)
        function tf=connected(adj,i,j)
            if i==j
                tf=true;
                return
            end

            neighbours=adj(i,:);
            target=false(1,size(adj,2));
            target(j)=true;
            notVisited=true(size(adj,1),1);
            while ~isempty(neighbours)
                if any(any(neighbours & target(ones(size(neighbours,1),1),:)))
                    tf=true;
                    return
                end
                newNeighbours=any(neighbours,1)' & notVisited;
                notVisited=notVisited & ~newNeighbours;
                neighbours=adj(newNeighbours,:);
            end
            tf=false;
        end
        function parent=directGraph(adjacency,nodeNames,root)
            if nargin<3
                root=LearnFunc.OccurrenceLearner.findRoot(adjacency);
            end

            cNodes=root;
            parent.(nodeNames{cNodes})=[];
            while ~isempty(cNodes)
                adjacency(:,cNodes)=false(size(adjacency,1),length(cNodes));
                nextNodes=false(size(adjacency,1),1);
                for n=1:length(cNodes)
                    children=find(adjacency(cNodes(n),:));
                    for c=1:length(children)
                        parent.(genvarname(nodeNames{children(c)}))=nodeNames{cNodes(n)};
                    end
                    nextNodes(children)=true;
                end
                cNodes=find(nextNodes);
            end
        end
        function root=findRoot(adjacency)
            function newNodes=getNewNodes(adjacency,costs,cCost,cIndex)
                newNodes=any(adjacency(:,costs(:,cIndex)==cCost),2);
            end

            leafs=find(sum(adjacency,2)==1);
            costs=zeros(size(adjacency,1),length(leafs));
            for i=1:length(leafs)
                costs(leafs(i),i)=1;
                cCost=1;
                newNodes=getNewNodes(adjacency,costs,cCost,i);
                while any(newNodes)
                    cCost=cCost+1;
                    costs(newNodes & costs(:,i)==0,i)=cCost;
                    newNodes=getNewNodes(adjacency,costs,cCost,i);
                end
            end

            [~,root]=min(sum(costs.*costs,2));
        end
    end
    
end

