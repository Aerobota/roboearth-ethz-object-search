function annotate(path)
    AnnoPath='/home/koenigst/Documents/MasterThesis/Koenig12/AnnotationTool';
    addpath(AnnoPath);
    addpath([AnnoPath '/LabelMeToolbox']);
    
    if path(1)~=filesep
        path=[pwd filesep path];
    end
    
    if path(end)~=filesep
        path=[path filesep];
    end
    
    fid=fopen([AnnoPath '/home-images.txt'],'wt');
    fprintf(fid,'%s',path);
    fclose(fid);
    
    if ~exist([path 'annotation'],'dir')
        [~,~,~]=mkdir([path 'annotation']);
    end
    
    fid=fopen([AnnoPath '/home-annotations.txt'],'wt');
    fprintf(fid,'%s',[path 'annotation']);
    fclose(fid);

    AnnotationTool
end