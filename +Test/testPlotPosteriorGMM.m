assert(isa(ll,'LearnFunc.LocationLearner') && iscellstr(classes),'Need to run testDistance first')

objects={'floor','window'};

ind1=ismember(classes,objects{1});
ind2=ismember(classes,objects{2});

post=ll.data.(objects{1}).(objects{2}).gmm.posterior(ll.data.samples{ind1,ind2});

figure
for i=1:size(post,2)
subplot(2,2,i)
scatter(ll.data.samples{ind1,ind2}(:,1),ll.data.samples{ind1,ind2}(:,2),[],post(:,i))
end