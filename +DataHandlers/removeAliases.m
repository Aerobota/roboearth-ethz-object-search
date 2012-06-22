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
    
    if isstruct(data)
        if isfield(data,'annotation')
            for i=1:length(data)
                for o=1:length(data(i).annotation.object)
                    try
                        data(i).annotation.object(o).name=genvarname(data(i).annotation.object(o).name);
                        data(i).annotation.object(o).name=alias.(data(i).annotation.object(o).name);
                    catch
                    end
                end
            end
        elseif isfield(data,'labels') && isfield(data,'names')
            data.names=genvarname(data.names);
            relabel=(1:length(data.names))';
            goodLabel=true(size(data.names));
            for i=1:length(data.names)
                if isfield(alias,data.names{i})
                    mem=ismember(data.names,alias.(data.names{i}));
                    if any(mem)
                        goodLabel(i)=false;
                        relabel(i)=relabel(mem);
                    else
                        data.names{i}=alias.(data.names{i});
                    end
                end
            end
            data.names=data.names(goodLabel);
            for i=1:size(data.labels,3)
                tmpLabel=data.labels(:,:,i);
                tmpLabel(tmpLabel~=0)=relabel(tmpLabel(tmpLabel~=0));
                data.labels(:,:,i)=tmpLabel;
            end
        else
            error('removeAliases:UnknownDataFormat','This function doesn''t recognise the input data');
        end
    else
        error('removeAliases:UnknownDataFormat','This function doesn''t recognise the input data');
    end
end