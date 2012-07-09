classdef ScoreEvidenceGenerator<LearnFunc.EvidenceGenerator
    %SCOREEVIDENCEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function evidence=getEvidence(obj,data,classes,varargin)
            doParallel=false;
            if nargin>=4
                if strcmpi('parallel',varargin{1})
                    doParallel=true;
                end
            end
            
            if doParallel
                evidence=obj.getEvidenceParallel(data,classes);
            else
                evidence=obj.getEvidenceSingle(data,classes);
            end
        end
    end
    
    methods(Access='protected')
        function evidence=getEvidenceParallel(~,data,classes)
            evidence=cell(size(classes));
            name2ind=LearnFunc.EvidenceGenerator.generateIndexLookup(classes);
            samples=[];
            parfor i=1:length(data)
                disp(['scanning image ' num2str(i)])
                tmpObjects=data.getObject(i);
                for o=1:length(tmpObjects)
                    newSample=[name2ind.(tmpObjects(o).name) tmpObjects(o).score tmpObjects(o).overlap];
                    samples=[samples;newSample];
                end
            end
            for i=1:length(evidence)
                evidence{i}=samples(samples(:,1)==i,2:end);
            end
        end
        
        function evidence=getEvidenceSingle(~,data,classes)
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

