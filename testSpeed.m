clear all

il=DataHandlers.QueryLoader('Dataset/DummySet',DataHandlers.DummyDetector());


while(il.cIndex<=il.nrImgs)
    tic
    try
        im=il.getData;
    catch
    end
    toc
end