clear all

N=1000;
NTests=1;

%% scoreEvidence

ds=DataHandlers.NYUDataStructure('../Koenig12/Dataset/NYU','train','det');
ds.load();
se=LearnFunc.ScoreEvidenceGenerator;

tic
e=se.getEvidence(ds);
singleTime=toc

tic
e=se.getEvidence(ds,'parallel');
parallelTime=toc



%% struct preallocation

tic
for i=1:NTests
    tmpCell=cell(N,1);
    outS1=struct('a',tmpCell,'b',tmpCell,'c',tmpCell,'d',tmpCell,'e',tmpCell);
end
structTime=toc

tic
for i=1:NTests
    outS2(N,1)=struct('a',cell(1,1),'b',cell(1,1),'c',cell(1,1),'d',cell(1,1),'e',cell(1,1));
end
repTime=toc


%% bsxfun vs logical repmat

in=rand(3,N);

tic
for d=size(in,1):-1:1
    tmp=in(d*ones(size(in,2),1),:);
    out1(:,:,d)=tmp-tmp';
end
logiTime=toc

tic
for d=size(in,1):-1:1
    out2(:,:,d)=bsxfun(@minus,in(d,:),in(d,:)');
end
bsxTime=toc
assert(all(all(all(out1==out2))),'Not the same');

%% cell vs assoc
names=cell(N,1);
for i=1:N
    names{i}=['dummy' num2str(i)];
    assoc.(names{i})=i;
end

nums=randperm(N);
nums=nums(1:NTests);
randomNames=cell(NTests,1);
for i=1:NTests
    randomNames{i}=names{nums(i)};
end


outCell=zeros(NTests,1);
outAssoc=zeros(NTests,1);

tic
for i=1:NTests
    outCell(i)=find(ismember(names,randomNames{i})==1);
end
timeCell=toc;

tic
for i=1:NTests
    outAssoc(i)=assoc.(randomNames{i});
end
timeAssoc=toc;

timeCell
timeAssoc
assert(all(outCell==outAssoc));