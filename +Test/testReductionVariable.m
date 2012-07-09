N=1000;
% data=randn(N,1);
class=(rand(N,1)<0.5)+1;
data=class;

samples=cell(2,1);
collection=[];
parfor i=1:length(data)
    newSample=[class(i) data(i)];
    collection=[collection;newSample];
end

for i=1:length(samples)
    samples{i}=collection(collection(:,1)==i,2);
end