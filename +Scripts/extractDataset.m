%% Parameters
sourceFolder='../NYU';
targetFolder='Dataset/NYU';
negativeSourceFolder='../Sun09/dataset';

%% Extraction
DataHandlers.convertFromNyuDataset(sourceFolder,negativeSourceFolder,targetFolder);