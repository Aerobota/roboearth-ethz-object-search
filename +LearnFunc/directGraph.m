function parent=directGraph(adjacency,nodeNames)
    root=findRoot(adjacency);
    
    cNodes=root;
    parent.(nodeNames{cNodes})=[];
    while ~isempty(cNodes)
        adjacency(:,cNodes)=false(size(adjacency,1),length(cNodes));
        nextNodes=false(size(adjacency,1),1);
        for n=1:length(cNodes)
            children=find(adjacency(cNodes(n),:));
            for c=1:length(children)
                parent.(nodeNames{children(c)})=nodeNames{cNodes(n)};
            end
            nextNodes(children)=true;
        end
        cNodes=find(nextNodes);
    end
end

function root=findRoot(adjacency)
    leafs=find(sum(adjacency,2)==1);
    costs=zeros(size(adjacency,1),length(leafs));
    for i=1:length(leafs)
        costs(leafs(i),i)=1;
        cCost=1;
        while any(costs(:,i)==0)
            newNodes=any(adjacency(:,costs(:,i)==cCost),2);
            cCost=cCost+1;
            costs(newNodes & costs(:,i)==0,i)=cCost;
        end
    end
    
    [~,root]=min(sum(costs.*costs,2));
end