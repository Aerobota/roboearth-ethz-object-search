function data=removeAliases(data)
    %DATA=REMOVEALIASES(DATA)
    %   Removes the aliases from the class names in DATA. The alias
    %   correspondences are hard coded. This function is mostly used if the
    %   data set contains identifiers for singular and plural cases of the
    %   same class, such as 'book' and 'books'.
    
    % The connection is alias.ALIASNAME=BASENAME
    alias.books='book';
    alias.bottles='bottle';
    alias.boxes='box';
    alias.cars='car';
    alias.rocks='stone';
    alias.rock='stone';
    alias.stones='stone';
    alias.pillow='cushion';
    alias.monitor='screen';
    
    data=removeAliasesNYU(data,alias);
end


function tmp_data=removeAliasesNYU(tmp_data,alias)
    % Enforce legal var names
    tmp_data.names=genvarname(tmp_data.names);
    % Initialize matrices
    relabel=(1:length(tmp_data.names))';
    myAlias=(1:length(tmp_data.names))';
    goodLabel=true(size(tmp_data.names));
    % For all labels in tmp_data
    for i=1:length(tmp_data.names)
        % Check if it's an alias
        if isfield(alias,tmp_data.names{i})
            % Check if the basename exists in the dataset
            mem=ismember(tmp_data.names,alias.(tmp_data.names{i}));
            if any(mem)
                % If basenames exist, flag that labels need to be changed
                goodLabel(i)=false;
                myAlias(i)=find(mem);
            else
                % If basename doesn't exist just rename the alias
                tmp_data.names{i}=alias.(tmp_data.names{i});
            end
        end
        % Prepare to remove any holes from the labels
        relabel(i)=sum(goodLabel(1:i));
    end
    % Remove any aliases from the name list
    tmp_data.names=tmp_data.names(goodLabel);
    for i=1:size(tmp_data.labels,3)
        % Relabel all pixels
        tmpLabel=tmp_data.labels(:,:,i);
        tmpLabel(tmpLabel~=0)=relabel(myAlias(tmpLabel(tmpLabel~=0)));
        tmp_data.labels(:,:,i)=tmpLabel;
    end
end