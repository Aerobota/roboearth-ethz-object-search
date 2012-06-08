function pop=pairwiseOccurenceProbability(samples,classes)
    states={'0','1','2+'};
    pop=zeros(length(classes),length(classes),length(states),length(states)); %pop(i,j,state_i,state_j)
    popDiag=zeros(length(classes),length(classes),length(states),length(states));
    
    nSamples=length(samples);
    
    if size(classes,1)==1
        classes=classes';
    end

    for s=1:nSamples
        objects={samples(s).annotation.object.name}';
        counts=zeros(length(classes),1);
        for o=1:length(objects)
            [~,id]=ismember(objects(o),classes);
            counts(id)=counts(id)+1;
        end
            
        for i=1:length(classes)
            popDiag=incrementProbability(popDiag,i,i,counts(i),max(counts(i)-1,0));
            for j=i+1:length(classes)
                pop=incrementProbability(pop,i,j,counts(i),counts(j));
            end
        end
    end
    
    pop=pop+permute(pop,[2 1 4 3])+popDiag;
    
    pop=pop/nSamples;
end

function array=incrementProbability(array,i,j,occi,occj)
    p=selectIndex(occi);
    q=selectIndex(occj);
    array(i,j,p,q)=array(i,j,p,q)+1;
end

function index=selectIndex(occurence)
    if occurence==0
        index=1;
    elseif occurence==1
        index=2;
    else
        index=3;
    end
end