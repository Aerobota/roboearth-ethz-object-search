function data=removeAliases(data)
    alias.books='book';
    alias.bottles='bottle';
    alias.boxes='box';
    alias.cars='car';
    alias.rocks='stone';
    alias.rock='stone';
    alias.stones='stone';
    alias.pillow='cushion';
    alias.monitor='screen';

    if isa(data,'DataHandlers.SunDataStructure')
        data=removeAliasesSun(data,alias);
    else
        data=removeAliasesNYU(data,alias);
    end
end


function tmp_data=removeAliasesNYU(tmp_data,alias)
    tmp_data.names=genvarname(tmp_data.names);
    relabel=(1:length(tmp_data.names))';
    myAlias=(1:length(tmp_data.names))';
    goodLabel=true(size(tmp_data.names));
    for i=1:length(tmp_data.names)
        if isfield(alias,tmp_data.names{i})
            mem=ismember(tmp_data.names,alias.(tmp_data.names{i}));
            if any(mem)
                goodLabel(i)=false;
                myAlias(i)=find(mem);
            else
                tmp_data.names{i}=alias.(tmp_data.names{i});
            end
        end
        relabel(i)=sum(goodLabel(1:i));
    end
    tmp_data.names=tmp_data.names(goodLabel);
    for i=1:size(tmp_data.labels,3)
        tmpLabel=tmp_data.labels(:,:,i);
        tmpLabel(tmpLabel~=0)=relabel(myAlias(tmpLabel(tmpLabel~=0)));
        tmp_data.labels(:,:,i)=tmpLabel;
    end
end


function data=removeAliasesSun(data,alias)
    for i=1:length(data)
        tmpObjects=data.getObject(i);
        for o=1:length(tmpObjects)
            tmpName=genvarname(tmpObjects(o).name);
            try
                tmpName=alias.(tmpName);
            catch
            end
            tmpObjects(o)=DataHandlers.ObjectStructure(tmpName,tmpObjects(o).score,tmpObjects(o).overlap,...
                tmpObjects(o).polygon.x,tmpObjects(o).polygon.y);
        end
        data.setObject(tmpObjects,i);
    end
end