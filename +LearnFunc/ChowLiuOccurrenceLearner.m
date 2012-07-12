classdef ChowLiuOccurrenceLearner<LearnFunc.ChowLiuLearner
    %CHOWLIUOCCURENCELEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=ChowLiuOccurrenceLearner(evidenceGenerator)
            obj=obj@LearnFunc.ChowLiuLearner(LearnFunc.PairwiseOccurrenceMutInf(evidenceGenerator));
        end
    end
end