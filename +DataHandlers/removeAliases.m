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
    
    for i=1:length(data)
        for o=1:length(data(i).annotation.object)
            try
                data(i).annotation.object(o).name=alias.(data(i).annotation.object(o).name);
            catch
            end
        end
    end
end