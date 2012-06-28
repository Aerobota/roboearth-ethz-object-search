classdef ChowLiuLocationLearner<LearnFunc.ChowLiuLearner
    %LOCATIONMUTINF Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=ChowLiuLocationLearner(classes,evidenceGenerator)
            obj=obj@LearnFunc.ChowLiuLearner(classes,LearnFunc.LocationMutInf(evidenceGenerator));
        end
    end
end