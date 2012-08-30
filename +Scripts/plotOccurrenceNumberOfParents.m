%% parameters

standardValueMatrix=2;
standardOccurrenceState=1;

%% Initialise

assert(exist('occLearner','var')==1,...
    'Scripts.computeOccurrenceData needs to be run before this script.')

%% Count parents

for p=size(occLearner,3):-1:1
    tmpNames=occLearner{standardValueMatrix,standardOccurrenceState,p}.getLearnedClasses();
    for i=length(tmpNames):-1:1
        nParents(i,p)=length(occLearner{standardValueMatrix,standardOccurrenceState,p}.model...
            .(tmpNames{i}).parents);
    end
end

%% Plot

figure()
boxplot(nParents,1:2,'labels',{'dependent','naive'})

title('number of parents')

%% Clear temporaries

clear('p','i','nParents','tmpNames','standardValueMatrix','standardOccurrenceState')