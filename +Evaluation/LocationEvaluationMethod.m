classdef LocationEvaluationMethod
    %LOCATIONEVALUATIONMETHOD Abstract Location Evaluation Method
    %   This is an interface for methods to evaluate the location
    %   performance.
    %
    %See also EVALUATION.LOCATIONEVALUATIONMETHOD.SCORECLASS,
    %   EVALUATION.LOCATIONEVALUATIONMETHOD.COMBINERESULTS
    
    properties(Abstract,Constant)
        % A string containing the designation of the method
        designation
    end
    
    properties(Constant)
        % The number of desired data points
        nThresh=100
    end
    
    methods(Abstract)
        %RESULT=SCORECLASS(OBJ,INRANGE,CANDIDATEPROB)
        %
        %INRANGE is a mxn boolean matrix where m is the number of objects
        %   of the sought class in this image and n the number of candidate
        %   points. If INRANGE(i,j) is true this means that object i is inside
        %   the maximum distance to candidate point j.
        %
        %CANDIDATEPROB is a 1xn matrix denoting the probabilities of the
        %   candidate points.
        %
        %RESULT is a matrix or struct that is collected by the
        %   LOCATIONEVALUATOR and will later be consumed by
        %   LOCATIONEVALUATIONMETHOD.COMBINERESULTS
        %
        %See also EVALUATION.LOCATIONEVALUATOR,
        %   EVALUATION.LOCATIONEVALUATIONMETHOD.COMBINERESULTS
        result=scoreClass(obj,inRange,candidateProb)
        
        %RESULT=COMBINERESULTS(OBJ,COLLECTEDRESULTS,CLASSESSMALL)
        %
        %COLLECTEDRESULTS is a mxn cell array where m is the number of
        %   images evaluated and n the number of sought classes. The content
        %   of each cell is the result returned by
        %   LOCATIONEVALUATIONMETHOD.SCORECLASS for the specific combination
        %   of image and class.
        %
        %CLASSESSMALL is a 1xn cell string array with the names of the n
        %   classes.
        %
        %RESULT is a format than can be consumed by a corresponding
        %   EVALUATIONDATA
        %
        %See also EVALUATION.LOCATIONEVALUATIONMETHOD.SCORECLASS,
        %   EVALUATION.EVALUATIONDATA
        result=combineResults(obj,collectedResults,classesSmall)
    end
end

