% Change from class to struct
% So that data can be loaded with SciPy

path = 'Dataset/Images/object/';
newpath = 'Dataset/Images/objectPython/';

mkdir(newpath);
% include the folders 
listing_folders = dir(path);

% skip the first two because they are '.' and '..'
for i = 3:length(listing_folders)
    % make sure to create the subfolders
    mkdir(fullfile(newpath, listing_folders(i).name));
    % get the full subfoldername
    foldername = fullfile(path, listing_folders(i).name);
    listing_obj = dir(foldername);
    for j = 3:length(listing_obj)
        objname = fullfile(foldername, listing_obj(j).name);
        % load the object containing array of classes
        S = load(objname);
        obj = S.object;
        % consider preallocating s to increase speed
        for k = 1:length(obj)
            % convert the class to struct
            s(k) = struct(obj(k));
        end
        % save it in the newpath
        newfilename = fullfile(newpath, listing_folders(i).name, ...
                               listing_obj(j).name);
        save(newfilename, 's');
        clear s
    end
end