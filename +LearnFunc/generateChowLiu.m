function adjacency=generateChowLiu(pmi)
    adjacency=false(size(pmi));
    
    [~,ids]=sort(pmi(:),'descend');
    
    maxEdges=size(pmi,1)-1;
    nEdges=0;
    
    for s=1:length(ids)
        [i,j]=ind2sub(size(pmi),ids(s));
        if ~connected(adjacency,i,j)
            adjacency(i,j)=true;
            adjacency(j,i)=true;
            nEdges=nEdges+1;
        end
        if nEdges==maxEdges
            break;
        end
    end
end

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