thresh=-1.02;
datasetPath='Dataset/NYU';
imageName='img_00006.jpg';

tic
try
    img=ilgt.getDataByName(imageName);
catch
    ilgt=DataHandlers.NYUGTLoader(datasetPath);
    ilgt.bufferDataset(ilgt.trainSet);
    img=ilgt.getDataByName(imageName);
end
image=img.getColourImage(1);

det=DataHandlers.HOGDetector(thresh);
initTime=toc
tic
out=det.detectClass('bottle',image);
detectTime=toc

imshow(image)
for o=1:length(out)
    hold on
    plot(out(o).polygon.x,out(o).polygon.y)
end
hold off