classdef LocationEvaluator<Evaluation.Evaluator
    %LOCATIONEVALUATOR Master Class for Evaluating Location Models
    %   This class implements the EVALUATE method from the abstract
    %   EVALUATOR class and supplies the two static methods
    %   PROBABILITYVECTOR and GETCANDIDATEPOINTS.
    %
    %See also EVALUATION.EVALUATOR,
    %   EVALUATION.LOCATIONEVALUATOR.PROBABILITYVECTOR,
    %   EVALUATION.LOCATIONEVALUATOR.GETCANDIDATEPOINTS
    
    
    methods
        function result=evaluate(obj,testData,locationLearner,evaluationMethods,maxDistances)
            %RESULT=EVALUATE(OBJ,TESTDATA,LOCATIONLEARNER,EVALUATIONMETHODS,MAXDISTANCES)
            %   This method evaluates LOCATIONLEARNER on the TESTDATA using
            %   the EVALUATIONMETHODS and MAXDISTANCES. The returned RESULT
            %   is structure that contains data to be consumed by the
            %   appropriate EVALUATION.EVALUATIONDATA.
            %
            %See also EVALUATION.EVALUATIONDATA
            
            % Get the small classes
            classesSmall=testData.getSmallClassNames();
            % All results will be collected in this collector
            resultCollector=cell(length(testData),length(classesSmall),length(evaluationMethods),length(maxDistances));
            parfor i=1:length(testData)
                disp(['collecting data for image ' num2str(i)])
                % For the current image get all small classes in this image
                % and all the objects belonging to these classes
                [goodClasses,goodObjects]=obj.getGoodClassesAndObjects(testData,i);
                % If there are goodClasses in the image
                if ~isempty(goodClasses)
                    % Get the probability distribution over the scenes
                    % point cloud and the location of each point in the
                    % cloud.
                    [probVec,locVec]=obj.probabilityVector(testData,i,locationLearner,classesSmall(goodClasses));
                    tmpResult=cell(1,length(classesSmall),length(evaluationMethods),length(maxDistances));
                    for c=goodClasses
                        for d=1:length(maxDistances)
                            % Generate candidate points and evaluate them
                            [inRange,candidateProb]=obj.getCandidatePoints(...
                                probVec.(classesSmall{c}),locVec,[goodObjects.(classesSmall{c}).pos],maxDistances(d));
                            for e=1:length(evaluationMethods)
                                % For each evaluationMethod compute the
                                % score
                                tmpResult{1,c,e,d}=evaluationMethods{e}.scoreClass(inRange,candidateProb);
                            end
                        end
                    end
                    % Put the results in one cell array, otherwise it won't
                    % work with parfor
                    resultCollector(i,:,:,:)=tmpResult;
                end
            end
            % Reformat the result array into a structure
            for e=1:length(evaluationMethods)
                for d=1:length(maxDistances)
                    result.(evaluationMethods{e}.designation){d}=evaluationMethods{e}.combineResults(resultCollector(:,:,e,d),classesSmall);
                end
            end
            result.maxDistances=maxDistances;
            result.classes=classesSmall;
        end
    end
    
    methods(Static)
        function [probVec,locVec]=probabilityVector(data,index,locationLearner,targetClasses)
            %[PROBVEC,LOCVEC]=PROBABILITYVECTOR(DATA,INDEX,LOCATIONLEARNER,TARGETCLASSES)
            %   Returns the probability of each point in the scenes point
            %   cloud and the position of each point.
            %
            %DATA is an implementation of a DataHandlers.DataStructure
            %   containing the test data.
            %
            %INDEX is a scalar index of the desired scene.
            %
            %LOCATIONLEARNER is an implementation of a
            %   LearnFunc.LocationLearner.
            %
            %TARGETCLASSES is a 1xn cell string array containing the names
            %   of the classes for which output is to be generated.
            %
            %PROBVEC is a struct where the fields are the names of the
            %   TARGETCLASSES where every field contains a vector with a
            %   probability for every point in the cloud.
            %
            %LOCVEC is a 3xn matrix where each column is the 3D-position of
            %   a point of the cloud.
            %
            %See also DATAHANDLERS.DATASTRUCTURE, LEARNFUNC.LOCATIONLEARNER
            
            % Get the scenes evidence via the evidenceGenerator
            evidence=locationLearner.evidenceGenerator.getEvidenceForImage(data,index);
            
            probVec=struct;
            % For each class and observed object compute the pairwise
            % probability
            for c=1:length(targetClasses)
                goodObjects=true(size(evidence.relEvi,1),1);
                for o=size(evidence.relEvi,1):-1:1
                    try
                        probVec.(targetClasses{c})(o,:)=locationLearner.getProbabilityFromEvidence(squeeze(evidence.relEvi(o,:,:)),evidence.names{o},targetClasses{c});
                    catch tmpError
                        if any(strcmpi(tmpError.identifier,{'MATLAB:nonExistentField','MATLAB:nonStrucReference'}))
                            goodObjects(o)=false;
                        else
                            tmpError.rethrow();
                        end
                    end
                end
                % Compute the mean of the pairwise probabilities if no
                % such exist just make an uniform distribution.
                if isfield(probVec,targetClasses{c})
                    probVec.(targetClasses{c})=mean(probVec.(targetClasses{c})(goodObjects,:),1);
                else
                    probVec.(targetClasses{c})=1/size(evidence.absEvi,2)*ones(1,size(evidence.absEvi,2));
                end
            end

            % Extract the point cloud locations from the evidence
            locVec=evidence.absEvi;
        end
        
        function [inRange,candidateProb,candidatePoints]=getCandidatePoints(probVec,locVec,truePos,maxDistance)
            %[INRANGE,CANDIDATEPROB,CANDIDATEPOINTS]=GETCANDIDATEPOINTS(PROBVEC,LOCVEC,TRUEPOS,MAXDISTANCE)
            %   Generates candidatePoints and computes if they are inside a
            %   maximal distance to any groundtruth object of the correct
            %   class.
            %
            %PROBVEC is a single field(i.e. class) from the struct returned
            %   by Evaluation.LocationEvaluator.probabilityVector.
            %
            %LOCVEC is the array of the same name returned as well by 
            %   Evaluation.LocationEvaluator.probabilityVector.
            %
            %TRUEPOS is the real 3D-location of the ground truth objects.
            %
            %MAXDISTANCE is the scalar maximum distance in metres that a
            %   candidate point can have to a ground truth object and be
            %   counted as inRange.
            %
            %INRANGE is a nxm boolean matrix that denotes if candidate
            %   point m is inside MAXDISTANCE to ground truth object n.
            %
            %CANDIDATEPROB is a a 1xm denoting the probability of each
            %   candidate point.
            %
            %CANDIDATEPOINTS is a 3xm matrix where each column is the
            %   position of one candidate point
            %
            %See also EVALUATION.LOCATIONEVALUATOR.PROBABILITYVECTOR
            
            % Sort the point cloud by decreasing probability
            [probVec,permIndex]=sort(probVec,'descend');
            locVec=locVec(:,permIndex);

            candidatePoints=[];
            candidateProb=[];
            while ~isempty(locVec)
                % Fit a candidate point to the location of highest
                % probability
                candidatePoints(:,end+1)=locVec(:,1);
                candidateProb(1,end+1)=probVec(:,1);
                % Remove all cloud points in range of the new point
                [probVec,locVec]=Evaluation.LocationEvaluator.removeCoveredPoints(...
                    probVec,locVec,candidatePoints(:,end),maxDistance);
            end

            inRange=false(size(truePos,2),size(candidatePoints,2));
            if ~isempty(truePos)
                % Check which candidate points are in range of ground truth
                % objects
                candidatePoints=permute(candidatePoints,[3 2 1]);
                truePos=permute(truePos,[2 3 1]);
                inRange=sum((truePos(:,ones(1,size(candidatePoints,2)),:)-...
                    candidatePoints(ones(1,size(truePos,1)),:,:)).^2,3)<maxDistance^2;
            end
        end
    end
    
    methods(Static,Access='protected')        
        function [goodClasses,goodObjects]=getGoodClassesAndObjects(data,index)
            % Check which objects actually occur in this scene and remove
            % all classes that have no object in the scene. Save all
            % objects of the small classes in goodObjects.
            classesSmall=data.getSmallClassNames();
            tmpObjects=data.getObject(index);
            
            goodObjects=struct;
            goodClasses=1:length(classesSmall);
            goodClassChooser=true(size(goodClasses));
            for c=goodClasses
                tmpChooser=ismember({tmpObjects.name},classesSmall{c});
                if any(tmpChooser)
                    goodObjects.(classesSmall{c})=tmpObjects(tmpChooser);
                else
                    goodClassChooser(c)=false;
                end
            end
            
            goodClasses=goodClasses(goodClassChooser);
        end        
        
        function [probVec,locVec]=removeCoveredPoints(probVec,locVec,point,maxDistance)
            % Remove all points inside maxDistance of the candidate point
            pointsOutside=sum((point(:,ones(1,size(locVec,2)))-locVec).^2,1)>maxDistance^2;
            locVec=locVec(:,pointsOutside);
            probVec=probVec(:,pointsOutside);
        end
    end
end

