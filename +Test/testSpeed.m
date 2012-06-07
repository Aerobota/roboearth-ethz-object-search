clear all

% il=DataHandlers.QueryLoader('Dataset/DummySet',DataHandlers.DummyDetector());
% 
% 
% while(il.cIndex<=il.nrImgs)
%     tic
%     try
%         im=il.getData;
%     catch
%     end
%     toc
% end


N=1000;
NTests=100;

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