classdef ChowLiuOccurrenceLearner<LearnFunc.ChowLiuLearner
    %CHOWLIUOCCURENCELEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=ChowLiuOccurrenceLearner(states,classes)
            obj=obj@LearnFunc.ChowLiuLearner(classes,LearnFunc.PairwiseOccurrenceMutInf(states));
        end
    end
end