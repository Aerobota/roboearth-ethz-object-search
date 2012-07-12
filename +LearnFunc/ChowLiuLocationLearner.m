classdef ChowLiuLocationLearner<LearnFunc.ChowLiuLearner
    %LOCATIONMUTINF Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=ChowLiuLocationLearner(evidenceGenerator)
            obj=obj@LearnFunc.ChowLiuLearner(LearnFunc.LocationMutInf(evidenceGenerator));
        end
    end
end