%% Check loaded model

assert(isa(locLearnCylindricGMM,'LearnFunc.ContinuousGMMLearner'),'Run script computeLocationData first.')

%% Parameters

doPlots=false;

imageNameCol{1}='img_00054.jpg';
targetClassCol{1}='book';

imageNameCol{2}='img_00296.jpg';
targetClassCol{2}='bottle';

imageNameCol{3}='img_00412.jpg';
targetClassCol{3}='faucet';

imageNameCol{4}='img_00878.jpg';
targetClassCol{4}='vase';

imageNameCol{5}='img_00689.jpg';
targetClassCol{5}='book';

imageNameCol{6}='img_00355.jpg';
targetClassCol{6}='book';

outputFileCommon='tmpImages/candPoints%%s%%d%s.png';
outputFileProb=sprintf(outputFileCommon,'Prob');
outputFileRGB=sprintf(outputFileCommon,'RGB');

for i=length(targetClassCol):-1:1
    imageNumbering(i)=sum(strcmpi(targetClassCol(1:i),targetClassCol{i}));
end

maxDistance=0.5;
maxCandidatePoints=5;

useGray=false;
colorRes=256;
probAlpha=0.7;

%% Initialisation

Scripts.setPaths

dataCol{1}=DataHandlers.NYUDataStructure(datasetPath,'train');
dataCol{1}.load()

dataCol{2}=DataHandlers.NYUDataStructure(datasetPath,'test');
dataCol{2}.load()

%% Generate images

for c=1:length(imageNameCol)
    imageName=imageNameCol{c};
    targetClass=targetClassCol{c};
    
    %% Find image
    
    for d=1:length(dataCol)
        for i=1:length(dataCol{d})
            if strcmpi(dataCol{d}.getFilename(i),imageName)==1
                data=dataCol{d};
                imageNumber=i;
            end
        end
    end

    %% Calculate probability density

    probDensity=zeros(data.getImagesize(imageNumber).nrows,data.getImagesize(imageNumber).ncols);
    [prob,loc]=Evaluation.LocationEvaluator.probabilityVector(data,imageNumber,locLearnCylindricGMM,{targetClass});
    probDensity(:)=prob.(targetClass);
    probDensity=(probDensity-min(probDensity(:)))/(max(probDensity(:)-min(probDensity(:))));

    %% Get candidate points

    [~,candProb,candPoints]=Evaluation.LocationEvaluator.getCandidatePoints(prob.(targetClass),loc,[],maxDistance);
    candPoints2D=data.getCalib(imageNumber)*candPoints;
    candPoints2D=round(candPoints2D(1:2,:)./candPoints([3 3],:));
    cImg=data.getColourImage(imageNumber);

    tmpH=figure();
    imshow(cImg)
    for i=1:maxCandidatePoints
        % font sizing doesn't work under unix but it does under windows
        text(candPoints2D(2,i),candPoints2D(1,i),num2str(i),'Color','r','FontName','times','FontSize',20,...
            'HorizontalAlignment','Center','BackgroundColor','w','EdgeColor','r')
    end

    F=getframe();
    close(tmpH)

    %% Blend probability image
    intensityImage=im2double(rgb2gray(cImg));
    intensityImage=(intensityImage-min(intensityImage(:)))/(max(intensityImage(:))-min(intensityImage(:)));

    if useGray
        probDensity=probAlpha*probDensity+(1-probAlpha)*intensityImage;
    else
        probDensity=ind2rgb(round((colorRes-1)*probDensity)+1,jet(colorRes));
        probDensity=probDensity.*(probAlpha*intensityImage(:,:,ones(size(probDensity,3),1))+1-probAlpha);
    end

    probDensity=(probDensity-min(probDensity(:)))/(max(probDensity(:)-min(probDensity(:))));


    %% Save images

    if ~exist(fileparts(outputFileProb),'dir')
        [~,~,~]=mkdir(fileparts(outputFileProb));
    end
    imwrite(F.cdata(1:end-1,1:end-1,:),sprintf(outputFileRGB,[upper(targetClass(1)) targetClass(2:end)],imageNumbering(c)))
    imwrite(probDensity,sprintf(outputFileProb,[upper(targetClass(1)) targetClass(2:end)],imageNumbering(c)))

    %% Display image
    
    if (doPlots)
        figure()
        subplot(1,2,1)
        imshow(F.cdata)

        subplot(1,2,2)
        imshow(probDensity,[min(probDensity(:)) max(probDensity(:))])
    end
end

%% Clear temporaries

clear('F','cImg','candPoints','candPoints2D','candProb','data','dataset',...
    'datasetPath','i','imageNumber','loc','maxCandidatePoints','maxDistance',...
    'outputFileProb','outputFileRGB','prob','probDensity','sourceFolder',...
    'targetClass','tmpH','probAlpha','intensityImage','dataCol','d','imageName',...
    'c','imageNameCol','targetClassCol','colorRes','doPlots','imageNumbering',...
    'useGray','outputFileCommon')
