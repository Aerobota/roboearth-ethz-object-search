function convertFromNyuDataset(inPath,outPath)
%CONVERTFROMNYUDATASET(INPATH,OUTPATH)
%   This function is used to convert the file 'nyu_depth_v2_labeled.mat'
%   found in folder INPATH to a format loadable by
%   DATAHANDLERS.NYUDATASTRUCTURE. The output files are saved in folder
%   OUTPATH. OUTPATH should be an empty folder as CONVERTFROMNYUDATASET
%   saves multiple files and folders into this directory.
% 
%   In addition to format conversion CONVERTFROMNYUDATASET also performs
%   other tasks:
%       - Replace aliases of classes with the base class ('books'->'book')
%       - Remove classes with 100 or less occurrences
%       - Split the dataset into two parts: a training set and a test set
% 
%   This function is parallelized and profits from MATLABPOOL OPEN.
% 
%   See also DATAHANDLERS.REMOVEALIASES, DATAHANDLERS.NYUDATASTRUCTURE

    % Generate the complete file path for the input file
    inFile=fullfile(inPath,'nyu_depth_v2_labeled.mat');

    % Generate paths for the image and depth folders of the output data
    % structure
    tmp_imageFolder=fullfile(outPath,DataHandlers.NYUDataStructure.imageFolder);
    tmp_depthFolder=fullfile(outPath,DataHandlers.NYUDataStructure.depthFolder);

    % Save the images as .jpg and the depth as .mat
    disp('extracting images')
    [imageNames,depthNames]=extractImages...
        (inFile,tmp_imageFolder,tmp_depthFolder);

    % Load the label and name data, then remove alias classes
    disp('loading other data')
    tmp_data=load(inFile,'labels','names');
    tmp_data=DataHandlers.removeAliases(tmp_data);
    % Do a random split into training and test set, true is training set
    disp('splitting dataset')
    split=rand(size(tmp_data.labels,3),1)<0.5;
    % Extract the classes that have more than 100 occurrences and save
    disp('extracting good classes')
    classes=extractGoodClasses(tmp_data.labels,tmp_data.names,outPath);

    % Extract all objects of the good classes and save
    extractObjects(split,imageNames,...
        depthNames,tmp_data.labels,tmp_data.names,classes,outPath,tmp_depthFolder)
end

function [imageNames,depthNames]=extractImages(inFile,tmp_imageFolder,tmp_depthFolder)
    % Set the image and depth name templates
    imageName='img_%05d.jpg';
    depthName='depth_%05d.mat';
    
    disp('loading image data')
    % Create image folder if necessary
    if ~exist(tmp_imageFolder,'dir')
        [~,~,~]=mkdir(tmp_imageFolder);
    end
    % Load image data from .mat file
    tmp_data=load(inFile,'images');

    % Write each image into a jpg and save the filename in imageNames
    disp('saving images')
    imageNames=cell(1,size(tmp_data.images,4));
    for i=1:size(tmp_data.images,4)
        imageNames{i}=sprintf(imageName,i);
        imwrite(tmp_data.images(:,:,:,i),fullfile(tmp_imageFolder,imageNames{i}));
    end

    % Clear the loaded images to free space
    clear('tmp_data')

    disp('loading depth data')
    % Create image folder if necessary
    if ~exist(tmp_depthFolder,'dir')
        [~,~,~]=mkdir(tmp_depthFolder);
    end
    % Load depth data from .mat file
    tmp_data=load(inFile,'depths');

    % Write each depth into a .mat and save the filename in depthNames
    disp('saving depth')
    depthNames=cell(1,size(tmp_data.depths,3));
    for i=1:size(tmp_data.depths,3)
        depthNames{i}=sprintf(depthName,i);
        depth=tmp_data.depths(:,:,i);
        save(fullfile(tmp_depthFolder,depthNames{i}),'depth')
    end
end

function tmp_names=extractGoodClasses(labels,tmp_names,outPath)
    % Initialize matrices
    counts=zeros(size(tmp_names));
    numbers=(1:length(tmp_names))';
    
    % Count the number of images each class appears in
    for i=1:size(labels,3)
        counts=counts+ismember(numbers,labels(:,:,i));
    end
    
    % Select all names that have more than 100 occurrences
    tmp_names=tmp_names(counts>100)';
    
    % Create the struct to be saved
    tmpSave.names=tmp_names;
    % Extract the small classes from all classes
    tmpSave.smallNames=DataHandlers.extractSmallClasses(tmp_names);
    % The other half are the large classes
    tmpSave.largeNames=setdiff(tmp_names,tmpSave.smallNames);
    % Save class name file
    save(fullfile(outPath,DataHandlers.NYUDataStructure.catFileName),'-struct','tmpSave');
end

function extractObjects(split,imageNames,depthNames,labels,allNames,goodClasses,outPath,tmp_depthFolder)
    disp('extracting training set')
    % Create an empty data structure for training data
    data=DataHandlers.NYUDataStructure(outPath,'train');
    % Fill data set with objects and other information
    extractImageSet(data,imageNames(1,split),depthNames(1,split),labels(:,:,split),allNames,goodClasses,tmp_depthFolder);
    % Save the full data structure
    data.save();

    clear('data')

    disp('extracting test set')
    % Create an empty data structure for test data
    data=DataHandlers.NYUDataStructure(outPath,'test');
    % Fill data set with objects and other information
    extractImageSet(data,imageNames(1,~split),depthNames(1,~split),labels(:,:,~split),allNames,goodClasses,tmp_depthFolder);
    % Save the full data structure
    data.save();
end

function extractImageSet(output,imageNames,depthNames,labels,allNames,goodClasses,tmp_depthFolder)
    % find which indices are from the good classes
    goodIndices=find(ismember(allNames,goodClasses));
    % Initialize matrices
    nImg=length(imageNames);
    subN=round(nImg/10);
    tmpCalib=cell(1,nImg);
    tmpObjects=cell(1,nImg);
    
    % In parallel extract objects and save in cell
    parfor i=1:nImg
        % Progress update (useless in parallel processing)
        if mod(i,subN)==0
            disp(['analysing image ' num2str(i) '/' num2str(nImg)])
        end
        % Get the depth data for the current image
        loaded=load(fullfile(tmp_depthFolder,depthNames{i}),'depth');
        % Get the calibration matrix (this is the default for the MS Kinect
        tmpCalib{i}=[525 0 239.5;0 525 319.5;0 0 1];
        % Detect the objects and return a collection of Object3DStructures
        tmpObjects{i}=detectObjects(labels(:,:,i),...
            allNames,goodIndices,loaded.depth,tmpCalib{i});
    end
    
    % Create the images and add them to the data structure
    for i=nImg:-1:1
        output.addImage(i,imageNames{i},depthNames{i},'',[480 640],tmpObjects{i},tmpCalib{i});
    end
end

function object=detectObjects(labels,allNames,goodIndices,depth,calib)
    % Set all labels zero that are not of good classes
    goodLabels=ismember(labels,goodIndices);
    labels(~goodLabels)=0;
    % Initialize matrices
    instances=zeros(size(labels));
    currentIndex=1;
    lSize=size(labels);
    % Iterate over every pixel label
    for i=1:lSize(1)
        for j=1:lSize(2)
            % If the label is valid
            if labels(i,j)>0
                % Get neighbourhood current pixel
                nx=max(i-1,1):min(i+1,lSize(1));
                ny=max(j-1,1):min(j+1,lSize(2));
                % Get the IDs of the object instances in the neighbourhood
                nInst=instances(nx,ny);
                % Get only the instances that are of my own class and not 0
                nLabels=nInst(labels(nx,ny)==labels(i,j));
                nLabels=nLabels(nLabels~=0);
                if isempty(nLabels)
                    % There are no instances of my class in the
                    % neighbourhood, create new instance
                    instances(i,j)=currentIndex;
                    instanceConnection(1,currentIndex)=currentIndex;
                    currentIndex=currentIndex+1;
                else
                    % There are one or more instances of my class in the
                    % neighbourhood, select the one with the lowest ID.
                    instances(i,j)=min(nLabels);
                    % All other instances are now connected to current
                    % pixel and should have the same ID. Find what the
                    % other labels are.
                    otherLabels=nLabels(nLabels~=instances(i,j));
                    % Make an associative array that maps the other IDs to
                    % the lowest ID
                    for q=1:length(otherLabels)
                        instanceConnection(1,otherLabels(q))=instances(i,j);
                    end
                end
            end
        end
    end

    % Ensure that associative array always points to the lowest ID
    for i=1:length(instanceConnection)
        instanceConnection(i)=instanceConnection(instanceConnection(i));
    end
    % Initialize array
    compInstances=zeros(size(instanceConnection));
    % Get the unique IDs
    uniInstances=unique(instanceConnection);
    % Assign IDs without holes
    compInstances(uniInstances)=1:length(uniInstances);
    compInstances=compInstances(instanceConnection);
    % Change all pixel IDs to the unique, dense IDs
    instances(instances>0)=compInstances(instances(instances>0));

    % Create an Object3DStructure for every ID
    goodInstances=true(1,length(uniInstances));
    for o=length(uniInstances):-1:1
        % Select pixels belonging to current ID
        mask=instances==o;
        % Get the class of current object
        myLabel=labels(mask==true);
        % Get the pixel coordinates of the current ID
        [row,col]=find(mask);
        % Generate bounding box
        tmp=[min(row) max(row);min(col) max(col)];
        px=[tmp(1,1) tmp(1,1) tmp(1,2) tmp(1,2)];
        py=[tmp(2,1) tmp(2,2) tmp(2,2) tmp(2,1)];
        % Create Object3DStructure
        object(o)=DataHandlers.Object3DStructure(allNames{myLabel(1)},px,py,depth,calib);
        % If the bounding box is too small, flag as bad
        if min(abs(tmp(:,1)-tmp(:,2)))<5
            goodInstances(o)=false;
        end
    end
    % Remove flagged objects
    object=object(goodInstances);
end