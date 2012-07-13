classdef ChowLiuLearner<LearnFunc.StructureLearner
    %CHOWLIUOCCURENCELEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        mutInfEngine
    end
    
    methods
        function obj=ChowLiuLearner(mutualInformationEngine)
            obj.mutInfEngine=mutualInformationEngine;
        end
        function dependencies=learnStructure(obj,data)
            pmi=obj.mutInfEngine.mutualInformation(data);
            adjacency=obj.generateChowLiu(pmi);
            dependencies=obj.directGraph(adjacency,data.getClassNames);
        end
    end
    methods(Access='protected',Static)
        function adjacency=generateChowLiu(pmi)
            adjacency=false(size(pmi));

            [~,ids]=sort(pmi(:),'descend');

            maxEdges=size(pmi,1)-1;
            nEdges=0;

            for s=1:length(ids)
                [i,j]=ind2sub(size(pmi),ids(s));
                if ~LearnFunc.ChowLiuOccurrenceLearner.connected(adjacency,i,j)
                    adjacency(i,j)=true;
                    adjacency(j,i)=true;
                    nEdges=nEdges+1;
                end
                if nEdges==maxEdges
                    break;
                end
            end
        end
    end
end

