thresh=-1;
datasetPath='Dataset/NYU';
imageName='img_00005.jpg';

tic
try
    img=il.getDataByName(imageName);
catch
    il=DataHandlers.NYUGTLoader(datasetPath);
    il.bufferDataset(il.trainSet);
    img=il.getDataByName(imageName);
end
image=imread(fullfile(il.path,il.imageFolder,img.annotation.filename));

det=DataHandlers.HOGDetector(thresh);
initTime=toc
tic
out=det.detectClass('table',image);
detectTime=toc

imshow(image)
for o=1:length(out)
    hold on
    plot(out(o).polygon.x,out(o).polygon.y)
end
hold off