function clean=checkPath(dirty)
    if dirty(end)~=filesep
        clean=[dirty filesep];
    else
        clean=dirty;
    end
    if exist(clean,'dir')==0
        error('The specified directory was not found');
    end
end