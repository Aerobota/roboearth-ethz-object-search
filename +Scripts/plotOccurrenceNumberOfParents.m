%% parameters

standardValueMatrix=2;
standardOccurrenceState=1;

%% Initialise

assert(exist('occLearner','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Count parents

for p=size(occLearner,3):-1:1
    tmpNames=occLearner{standardValueMatrix,standardOccurrenceState,p}.getLearnedClasses();
    parentSet{p}=cell(0,1);
    for i=length(tmpNames):-1:1
        nParents(i,p)=length(occLearner{standardValueMatrix,standardOccurrenceState,p}.model...
            .(tmpNames{i}).parents);
        parentSet{p}=[parentSet{p} occLearner{standardValueMatrix,standardOccurrenceState,p}.model...
            .(tmpNames{i}).parents];
    end
    setSize(p)=length(unique(parentSet{p}));
end

%% Plot

figure()
boxplot(nParents,1:2,'labels',{'dependent','naive'})

title('number of parents')

%% Clear temporaries

clear('p','i','nParents','parentSet','tmpNames','standardValueMatrix','standardOccurrenceState')