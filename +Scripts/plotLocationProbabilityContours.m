%% Parameters

classPairs={...
    'sink','faucet';...
    'cabinet','bottle';...
    'bookshelf','book';...
    'cabinet','faucet'};

nPoints=200;

doContours=true;

nContours=20;

%% Check

assert(exist('locLearnCylindricGMM','var')==1,...
    'Scripts.computeLocationData needs to be run before this script.')

%% Calculate Probabilities


tmpProb=zeros(nPoints);
if doContours
    quantileSteps=1-(linspace(0,1,nContours)-1).^2;
    quantileSteps=quantileSteps(2:end-1);
end

for c=1:size(classPairs,1)
    myMeans=locLearnCylindricGMM.model.(classPairs{c,1}).(classPairs{c,2}).mean;
    rmax=round(2*max(myMeans(1,:))+1)/2;
    zmin=round(2*min(myMeans(2,:))-1)/2;
    zmax=round(2*max(myMeans(2,:))+1)/2;
    
    delta=rmax-zmax+zmin;
    if delta<0
        rmax=zmax-zmin;
    else
        zmax=zmax+delta/2;
        zmin=zmin-delta/2;
    end
    
    [r,z]=meshgrid(linspace(0,zmax-zmin,nPoints),linspace(zmin,zmax,nPoints));
    tmpEvidence=[r(:) z(:)];
    
    tmpProb(:)=locLearnCylindricGMM.getProbabilityFromEvidence(tmpEvidence,classPairs{c,1},classPairs{c,2});
    
    
    
    figure()
    if doContours
        tmpQuantiles=quantile(tmpProb(:),quantileSteps);
        contour(r,z,tmpProb,tmpQuantiles)
        meanColour='k';
    else
        pcolor(r,z,tmpProb)
        shading('interp')
        meanColour='g';
    end
    hold('on')
    plot(myMeans(1,:),myMeans(2,:),['*' meanColour])
    hold('off')
    colorbar()
    axis('equal')
    xlabel('radius [m]')
    ylabel('height [m]')
    title(['probability distribution for relative position from ' classPairs{c,1} ' to ' classPairs{c,2}])
end

%% Clear temporaries

clear('r','z','c','classPairs','nPoints','zmin','zmax','tmpEvidence','tmpProb',...
    'tmpQuantiles','quantileSteps','nContours','delta','doContours','meanColour','myMeans','rmax');
