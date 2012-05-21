function annotate(path)
    % clean path
    if path(1)~=filesep
        path=[pwd filesep path];
    end
    
    if path(end)~=filesep
        path=[path filesep];
    end
    
    % rollback annotations
    if exist([path 'combined'],'dir')
        [~,~,~]=rmdir([path 'combined']);
    end
    
    files=dir([path 'annotation/anno_*']);
    files.name
    if ~exist([path 'annotation/image'],'dir')
        mkdir([path 'annotation/image']);
    end
    
    for i=1:length(files)
        [~,tmpName,tmpExt]=fileparts(files(i).name);
        tmpName=sscanf(tmpName,'anno_%s');
        movefile([path 'annotation/' files(i).name],...
            [path 'annotation/image/img_' tmpName tmpExt]);
    end

    % setup matlab path
    AnnoPath=[pwd '/AnnotationTool'];
    addpath(AnnoPath);
    addpath([AnnoPath '/LabelMeToolbox']);
    
    % setup paths for annotation tool
    fid=fopen([AnnoPath '/home-images.txt'],'wt');
    fprintf(fid,'%s',path);
    fclose(fid);
    
    if ~exist([path 'annotation'],'dir')
        [~,~,~]=mkdir([path 'annotation']);
    end
    
    fid=fopen([AnnoPath '/home-annotations.txt'],'wt');
    fprintf(fid,'%s',[path 'annotation']);
    fclose(fid);

    % launch annotation tool
    AnnotationTool
end