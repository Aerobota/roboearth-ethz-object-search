classdef ContinuousGMMLearner<LearnFunc.LocationLearner
    %CONTINUOUSGMMLEARNER Models relative location as a mixture of gaussian
    %   This method a used to learn a mixture of gaussians model of the
    %   distribution of relative locations between object pairs.
    properties(Constant)
        maxComponents=5;
    end
    
    methods
        function obj=ContinuousGMMLearner(evidenceGenerator)
            obj=obj@LearnFunc.LocationLearner(evidenceGenerator);
        end
        
        function prob=getProbabilityFromEvidence(obj,evidence,fromClass,toClass)
            if isvector(evidence)
                if size(evidence,1)==1
                    evidence=evidence';
                end
            end
            prob=obj.model.(fromClass).(toClass).gmm.pdf(evidence);
        end
        
        function learn(obj,data)
            % Get the relative location samples
            samples=obj.evidenceGenerator.getEvidence(data);
            classes=data.getClassNames();
            % For efficient use with parfor the data needs to be in a
            % vector format for slicing
            slicedSamples=cell(size(samples,1),1);
            slicedOutput=cell(length(classes),1);
            for i=1:length(slicedSamples)
                slicedSamples{i}=samples(i,:);
            end
            for i=1:length(classes)
                for j=1:length(classes)
                    % Check that enough samples are available
                    if size(slicedSamples{i}{j},1)>=obj.minSamples;
                        % Compute the GMM
                        [tmpMean,tmpCov,tmpCoeff,tmpGMM]=LearnFunc.ContinuousGMMLearner.doGMM(slicedSamples{i}{j});
                        % If a GMM was learned save it
                        if ~isempty(tmpMean)
                            slicedOutput{i}.(classes{j}).mean=tmpMean;
                            slicedOutput{i}.(classes{j}).cov=tmpCov;
                            slicedOutput{i}.(classes{j}).mixCoeff=tmpCoeff;
                            slicedOutput{i}.(classes{j}).gmm=tmpGMM;
                            slicedOutput{i}.(classes{j}).nrSamples=size(slicedSamples{i}{j},1);
                        end
                    end
                end
                disp(['finished with class ' classes{i}])
            end
            % Take the sliced output and convert it into a struct
            for i=1:length(classes)
                obj.model.(classes{i})=slicedOutput{i};
            end
        end
    end
    methods(Static,Access='protected')
        function [outMean,outCov,outCoeff,gmm]=doGMM(samples)
            % Split the dataset into 3 parts, use 2 parts for training and
            % 1 for testing
            randomIndices=randperm(size(samples,1));
            split=ceil(length(randomIndices)/3);
            % Generate every possible combination
            test={samples(randomIndices(1:split),:),...
                samples(randomIndices(split+1:2*split),:),...
                samples(randomIndices(2*split+1:end),:)};
            train={[samples(randomIndices(split+1:2*split),:);samples(randomIndices(2*split+1:end),:)],...
                [samples(randomIndices(1:split),:);samples(randomIndices(2*split+1:end),:)],...
                [samples(randomIndices(1:split),:);samples(randomIndices(split+1:2*split),:)]};
            score=zeros(LearnFunc.ContinuousGMMLearner.maxComponents,1);
            % For every possible number of components calculate the score
            for k=1:LearnFunc.ContinuousGMMLearner.maxComponents
                % Add the scores for all dataset splits
                for s=1:length(train)
                    score(k)=score(k)+LearnFunc.ContinuousGMMLearner.evaluateModelComplexity(train{s},test{s},k);
                end
            end
            
            % Find the lowest cost
            [~,kOpt]=min(score);
            try
                % Train a GMM with the optimal number of components and the
                % complete dataset
                gmm=gmdistribution.fit(samples,kOpt);
            catch
                % If training fails return no data
                outMean=[];
                outCov=[];
                outCoeff=[];
                gmm=[];
                return
            end
            % Save the learned model
            outMean=gmm.mu';
            outCov=gmm.Sigma;
            outCoeff=gmm.PComponents;
        end   
        function score=evaluateModelComplexity(trainSet,testSet,k)
            warning('off','stats:gmdistribution:FailedToConverge')
            try
                % Train a GMM on the training data
                gmm=gmdistribution.fit(trainSet,k);
                % Get the log-likelihood of the test data
                [~,NLogN]=gmm.posterior(testSet);
            catch
                % If training fails score is infinite
                score=inf;
                return
            end
            % Compute the BIC score
            [n,d]=size(testSet);
            score=2*NLogN+(k*d^2/2+1.5*k*d+k-1)*log(n);
        end
    end
end