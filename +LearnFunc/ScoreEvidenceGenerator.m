classdef ScoreEvidenceGenerator<LearnFunc.EvidenceGenerator
    %SCOREEVIDENCEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function evidence=getEvidence(~,data,classes,~)
            evidence=cell(size(classes));
            name2ind=LearnFunc.EvidenceGenerator.generateIndexLookup(classes);
            for i=1:length(data)
                disp(['scanning image ' num2str(i)])
                tmpObjects=data.getObject(i);
                for o=1:length(tmpObjects)
                    evidence{name2ind.(tmpObjects(o).name)}(end+1,:)=[tmpObjects(o).score tmpObjects(o).overlap];
                end
            end
        end
    end    
end

