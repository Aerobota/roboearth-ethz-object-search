eviGen=LearnFunc.CylindricEvidenceGenerator();

n=1:5;
tmpPos=[n;mod(n,2);3-n]

for i=5:-1:1
    image.annotation.object(i).pos=tmpPos(:,i);
end

e=eviGen.getRelativeEvidence(image)