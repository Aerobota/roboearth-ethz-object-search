%% Parameters
sourceFolder='../NYU';
targetFolder='Dataset/NYU_new';
negativeSourceFolder='../Sun09/dataset';

%% Extraction
sourcePath=fullfile(pwd,sourceFolder);
targetPath=fullfile(pwd,targetFolder);

negativeDataLoader=DataHandlers.SunGTLoader(fullfile(pwd,negativeSourceFolder));

il=DataHandlers.NYUConverter(sourcePath,targetPath,negativeDataLoader);

il.convertFromNyuDataset()