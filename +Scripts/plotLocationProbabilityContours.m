%% Parameters

classPairs={...
    'sink','faucet';...
    'sink','bottle';...
    'bookshelf','book';...
    'cabinet','faucet'};

nPoints=200;
nContours=20;
zmin=-1.5;
zmax=2.5;

%% Check

assert(exist('locLearnCylindricGMM','var')==1,...
    'Scripts.computeLocationData needs to be run before this script.')

%% Calculate Probabilities

[r,z]=meshgrid(linspace(0,zmax-zmin,nPoints),linspace(zmin,zmax,nPoints));
tmpEvidence=[r(:) z(:)];
tmpProb=r;
quantileSteps=1-(linspace(0,1,nContours)-1).^2;
quantileSteps=quantileSteps(2:end-1);

for c=1:size(classPairs,1)
    tmpProb(:)=locLearnCylindricGMM.getProbabilityFromEvidence(tmpEvidence,classPairs{c,1},classPairs{c,2});
    
    
    tmpQuantiles=quantile(tmpProb(:),quantileSteps);
    
    figure()
    contour(r,z,tmpProb,tmpQuantiles)
    colorbar()
    axis('equal')
    xlabel('radius')
    ylabel('height')
    title(['probability distribution for relative position from ' classPairs{c,1} ' to ' classPairs{c,2}])
end

%% Clear temporaries

clear('r','z','c','classPairs','nPoints','zmin','zmax','tmpEvidence','tmpProb',...
    'tmpQuantiles','quantileSteps','nContours');