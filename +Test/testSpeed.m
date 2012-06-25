clear all

N=1000;
NTests=100;

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