function extractDetections(groundTruthData,detector)
    

    data=runDetector(groundTruthData,...
        groundTruthLoader.path,detector);
    data.save()
end

function out=runDetector(data,detector)
    nData=length(data);
    collectedObjects=cell(1,nData);
    classes=data.getClassNames();
    parfor i=1:nData
        disp(['detecting image ' num2str(i) '/' num2str(nData)])
        for c=1:length(classes)
            tmpObjects=detector.detectClass(classes(c).name,...
                data.getColourImage(i));
            tmpDepth=data.getDepthImage(i);
            tmpOverlap=data.computeOverlap(tmpObjects,data.getObject(i),'complete');
            for o=1:length(tmpObjects)
                size(tmpDepth)
                disp(tmpObjects(o).polygon.x)
                disp(tmpObjects(o).polygon.y)
                collectedObjects{i}=[collectedObjects{i},...
                    DataHandlers.Object3DStructure(tmpObjects(o).name,...
                    tmpObjects(o).score,tmpOverlap(o),...
                    tmpObjects(o).polygon.x,tmpObjects(o).polygon.y,...
                    tmpLoaded.depth,data.getCalib(i))];
            end
        end
    end
    out=DataHandlers.NYUDataStructure(data.path,data.setChooser{1},DataHandlers.NYUDataStructure.det,nData);
    for i=1:nData    
        out.addImage(i,data.getFilename(i),data.getDepthname(i),data.getFolder(i),...
            data.getImagesize(i),collectedObjects{i},data.getCalib(i));
    end
end