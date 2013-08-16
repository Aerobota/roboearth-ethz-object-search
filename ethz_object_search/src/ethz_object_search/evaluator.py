'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

import numpy as np
import pickle


class Evaluator(object):
    '''
    Base class for evaluators
    This is the common base class for all classes evaluating a learned
    model.
    '''
    nThresh = 100
    savefile = 'resultsGMM'

    def __init__(self, maxDistList, evaluationMethod):
        '''
        Constructor.
        @attention: Unlike MATLAB version, used to set the maximum distances d_max
        and the evaluation methods.

        '''
        #maximum distances d_max
        #inside which the location predictor gets a positive score
        self.maxDistances = maxDistList
        #evaluation method
        self.evalMethod = evaluationMethod

    def evaluateAndDisplayResults(self, testData, locationLearner):
        '''
        First runs the evaluation process. Then it
        displays the results for the whole test dataset,
        in a suitable format given by METHOD.COMBINERESULTS.
        '''

        try:
            f = open(self.savefile, 'r')
            print 'Results have already been evaluated for the test dataset.'
            results = pickle.load(f)

        except IOError:
            print 'Evaluating test dataset...'
            results = self.evaluate(testData, locationLearner)
            # pickle the results
            f = open(self.savefile, 'w')
            pickle.dump(results, f)
            f.close()

        print 'Displaying evaluation results'

        # get the small classes
        classesSmall = testData.getSmallClassNames()

        # format the results
        res = Result(classesSmall, self.maxDistances)
        for method in self.evalMethod:
            res.methodResults[method.designation] = list()
            for maxDistance in self.maxDistances:
                inp = method.combineResults(results[method][maxDistance], classesSmall)
                res.methodResults[method.designation].append(inp)

        #TODO: what to do with res?


class LocationEvaluator(Evaluator):
    '''
    Master Class for Evaluating Location Models
    This class implements the EVALUATE method and supplies
    the two static methods PROBABILITYVECTOR and GETCANDIDATEPOINTS.
    '''

    def infer(self, semMap, smallObjects, locationLearner, maxDistance):
        '''
        This method infers the location of queried objects SMALLOBJECTS
        using SEMMAP. SMALLOBJECTS is a list of small object strings.

        Receives the pickled GMM models.

        Returns a dictionary CANDIDATEPOINTS
        which has small objects as keys and list of CANDIDATEPOINT structures
        as values.
        '''

        candidatePoints = dict()
        # Get the probability distributions over the scenes'
        # point cloud and the location of each point in the cloud.
        probVec, locVec = self.probabilitiesForSemMap(semMap, locationLearner, smallObjects)

        for c in smallObjects: # for each small object
            print "Generating candidate points for object", c.type
            # generate candidate points and evaluate them
            candidatePoints[c] = self.getCandidatePoints(probVec[c.type], locVec, maxDistance)

        return candidatePoints

    def evaluateOneImage(self, testData, imageNum, locationLearner, maxDistance, method):
        '''
        This method evaluates LOCATIONLEARNER on ONE IMAGE using
        one particular EVALUATIONMETHOD and MAXDISTANCE to save
        time. It does not return any results.
        '''

        # all results will be stored in this dictionary
        results = dict()
        image = testData.data[imageNum]
        print "Evaluating for image", image['filename']
        # For the current image get all small classes in this image
        # and all the objects belonging to these classes
        smallObjects = self.getOccurringClassesAndObjects(testData, image)
        # if there are small objects in the image
        if len(smallObjects) != 0:
            # Get the probability distributions over the scenes'
            # point cloud and the location of each point in the cloud.
            probVec, locVec = self.probabilitiesForImage(testData, image, locationLearner, smallObjects)
            for c in smallObjects.iterkeys(): # for each small object
                print "Generating candidate points for object", c
                # matrix of column stacked 3d positions
                truePos = locationLearner.evidenceGenerator.getPositionEvidence(smallObjects[c])
                # generate candidate points and evaluate them
                candidatePoints = self.getCandidatePoints(probVec[c], locVec, maxDistance)
                candidatePoints = self.evaluateCandidatePoints(truePos, candidatePoints, maxDistance)
                results[c] = method.scoreClass(candidatePoints)

        print 'Displaying search task results'
        for c in results.iterkeys():
            print 'Number of attempts to find object', c
            print 'inside radius', maxDistance, ':', results[c]

    def evaluate(self, testData, locationLearner):
        '''
        This method evaluates LOCATIONLEARNER on the TESTDATA using
        the EVALUATIONMETHODS and MAXDISTANCES. The returned RESULT
        is dictionary that contains data to be pickled or displayed
        using EVALUATOR.EVALUATEIMAGE.

        @attention: Unlike MATLAB, we're not running a parallel loop
        here so no need to keep track of extra stuff.
        '''

        # all results will be stored in this dictionary
        results = dict()

        for method in self.evalMethod:
        # for each evaluation method compute the score
            print "Evaluating with method", method.designation
            results[method] = dict()
            for maxDistance in self.maxDistances:
                print 'Using maximum distance metric of', maxDistance
                results[method][maxDistance] = dict()
                for image in testData.data:
                    results[method][maxDistance][image] = dict()
                    print "Collecting data for image", image['filename']
                    # For the current image get all small classes in this image
                    # and all the objects belonging to these classes
                    smallObjects = self.getOccurringClassesAndObjects(testData, image)
                    # if there are small objects in the image
                    if len(smallObjects) != 0:
                        # Get the probability distributions over the scenes'
                        # point cloud and the location of each point in the cloud.
                        probVec, locVec = self.probabilitiesForImage(testData, image, locationLearner, smallObjects)
                        for c in smallObjects.iterkeys(): # for each small object
                            print "Generating candidate points for object", c
                            # matrix of column stacked 3d positions
                            truePos = locationLearner.evidenceGenerator.getPositionEvidence(smallObjects[c])
                            # generate candidate points and evaluate them
                            candidatePoints = self.getCandidatePoints(probVec[c], locVec, maxDistance)
                            candidatePoints = self.evaluateCandidatePoints(truePos, candidatePoints, maxDistance)
                            results[method][maxDistance][image][c] = method.scoreClass(candidatePoints)

        return results

    def getOccurringClassesAndObjects(self, testData, image):
        '''
        Check which objects actually occur in this scene and remove
        all classes that have no object in the scene.

        Save all objects of the small classes in smallObjects
        as a dictionary of small classes.

        TODO: merge with SmallObject class perhaps?
        '''

        classesSmall = testData.getSmallClassNames()

        # get numpy array of structs, each struct corresponding to one object
        objs = testData.loadObjectMAT(image)
        names = testData.getNamesOfObjects(objs)

        smallObjects = dict()
        # use for indexing
        namesArray = np.array(names)

        for c in classesSmall:
            if names.count(c):
                smallObjects[str(c)] = objs[namesArray == c]

        return smallObjects

    def probabilitiesForSemMap(self, semMap, locationLearner, smallObjects):
        '''
        [PROBVEC,LOCVEC] = PROBABILITIESFORSEMMAP(SEMMAP,LOCLEARNER,SMALLOBJ)
        Returns the probability and position of each point in the scenes point
        cloud.

        The scene's point cloud is just the box containing the locations
        of the large objects pushed further by a certain threshold EPSILON.
        These are fields of the class originally set by the constructor.

        SEMMAP is an implementation of a SemMap structure containing
        SemMapObject list.

        LOCATIONLEARNER is an implementation of a Learner.LocationLearner.

        SMALLOBJECTS is a list of small objects queried for.

        PROBVEC is a dictionary of dictionaries
        with keys same as SMALLOBJECTS and OBSERVED OBJECTS
        where every entry is a vector of probabilities for every point in the cloud.

        LOCVEC is a 3xn numpy array where each column is the 3D-position of
        a point of the cloud.

        '''

        evidence = locationLearner.evidenceGenerator.getEvidenceForSemMap(semMap)

        probVec = dict()
        # For each (small object) class and observed object
        # compute the pairwise probability
        for c in smallObjects: # for each small object
            probVec[c.type] = dict()
            # for each (observed) large object
            for idx_o in range(evidence['relEvidence'].shape[0]):
                o = evidence['names'][idx_o]
                if o == 'unknown': continue
                # make sure object has unique identifier
                ind = 1; o_ind = o
                while o_ind in probVec[c.type]:
                    o_ind = o + str(ind)
                    ind = ind + 1
                # each row in mat should correspond to a single data point
                mat = np.squeeze(evidence['relEvidence'][idx_o, :, :])
                probVec[c.type][o_ind] = locationLearner.getProbabilityFromEvidence(mat, o, c.type)
            try:
                # Compute the mean of the pairwise probabilities
                probVec[c.type]['mean'] = np.sum(probVec[c.type].values(), 0) / len(probVec[c.type].values())
            except ZeroDivisionError:
                #observed large objects are apparently not in dataset
                # make a uniform distribution
                size = evidence['absEvidence'].shape[1]
                probVec[c.type]['mean'] = 1 / size * np.ones((1, size))

        # the absolute locations were returned with the evidence dictionary
        locVec = evidence['absEvidence']

        return probVec, locVec

    def probabilitiesForImage(self, data, image, locationLearner, smallObjects):
        '''
        [PROBVEC,LOCVEC] = PROBABILITIESFORIMAGE(DATA,IMAGE,LOCLEARNER,SMALLOBJ)
        Returns the probability of each point in the scenes point
        cloud and the position of each point.

        DATA is an implementation of a DataHandlers.DataStructure
        containing the test data.

        IMAGE is the desired scene.

        LOCATIONLEARNER is an implementation of a Learner.LocationLearner.

        SMALLOBJECTS is a dictionary with unique keys consisting of the names
        of the small classes for which output is to be generated.
        Objects are also numbered so that they are unique.

        PROBVEC is a dictionary of dictionaries
        with keys same as SMALLOBJECTS and OBSERVED OBJECTS
        where every entry is a vector of probabilities for every point in the cloud.

        LOCVEC is a 3xn numpy array where each column is the 3D-position of
        a point of the cloud.

        '''

        evidence = locationLearner.evidenceGenerator.getEvidenceForImage(data, image)

        probVec = dict()
        # For each (small object) class and observed object
        # compute the pairwise probability
        for c in smallObjects.iterkeys(): # for each small object
            probVec[c] = dict()
            # for each (observed) large object
            for idx_o in range(evidence['relEvidence'].shape[0]):
                o = evidence['names'][idx_o]
                if o == 'unknown': continue
                # make sure object has unique identifier
                ind = 1; o_ind = o
                while o_ind in probVec[c]:
                    o_ind = o + str(ind)
                    ind = ind + 1
                # each row in mat should correspond to a single data point
                mat = np.squeeze(evidence['relEvidence'][idx_o, :, :])
                probVec[c][o_ind] = locationLearner.getProbabilityFromEvidence(mat, o, c)
            try:
                # Compute the mean of the pairwise probabilities
                probVec[c]['mean'] = np.sum(probVec[c].values(), 0) / len(probVec[c].values())
            except ZeroDivisionError:
                #observed large objects are apparently not in dataset
                # make a uniform distribution
                size = evidence['absEvidence'].shape[1]
                probVec[c]['mean'] = 1 / size * np.ones((1, size))


        # the absolute locations were returned with the evidence dictionary
        locVec = evidence['absEvidence']
        return probVec, locVec

    def getCandidatePoints(self, probVec, locVec, maxDistance):
        '''
        [INRANGE,CANDIDATEPROB,CANDIDATEPOINTS]=GETCANDIDATEPOINTS(PROBVEC,LOCVEC,TRUEPOS,MAXDISTANCE)
        Generates candidatePoints.

        PROBVEC is a single field(i.e. class) from the struct returned
        by Evaluator.LocationEvaluator.probabilityVector.

        LOCVEC is the array of the same name returned as well by
        Evaluator.LocationEvaluator.probabilityVector.

        MAXDISTANCE is the scalar maximum distance in metres that a
        candidate point can have to a ground truth object and be
        counted as inRange.

        RETURNS a list of CANDIDATEPOINT structure where:

        INRANGE is a boolean n-vector that denotes if candidate
        point m is inside MAXDISTANCE to ground truth object n.
        This will be evaluated in the EVALUATECANDIDATEPOINTS method.

        CANDIDATEPROB denotes the probability of each
        candidate point.

        CANDIDATEPOS is a 3-vector showing position of the candidate point

        See also EVALUATOR.LOCATIONEVALUATOR.PROBABILITYVECTOR

        @attention: Unlike MATLAB code, here running a for loop to
        calculate range for candidate points
        '''

        # sort the point cloud by decreasing probability
        probs = probVec['mean']
        ind = probs.argsort()
        probs = probs[:, ind]
        locVec = locVec[:, ind]

        # list of candidate points
        candidatePoints = list()
        while locVec.shape[1] is not 0:
            # Fit a candidate point to the location of highest
            # probability
            newCand = CandidatePoint(probs[0], locVec[:, 0])
            candidatePoints.append(newCand)
            # Remove all cloud points in range of the new point
            probs, locVec = self.removeCoveredPoints(probs, locVec, newCand, maxDistance)

        return candidatePoints

    def evaluateCandidatePoints(self, truePos, candidatePoints, maxDistance):
        '''
        Evaluates candidate points.
        Computes if they are inside a maximal distance to any groundtruth
        object of the correct class.

        TRUEPOS is the real 3D-location of the ground truth objects.

        MAXDISTANCE is the scalar maximum distance in metres that a
        candidate point can have to a ground truth object and be
        counted as inRange.

        Returns candidate points that have inrange fields evaluated.
        '''

        if truePos.shape[1] is not 0:
            n = truePos.shape[1]
            # Check which candidate points are in range of ground truth
            # objects
            for cand in candidatePoints:
                dist = (cand.pos[:, np.newaxis] * np.ones((3, n))) - truePos
                cand.inrange = (sum(dist * dist) < (maxDistance * maxDistance))

        return candidatePoints

    def removeCoveredPoints(self, probVec, locVec, candPoint, maxDistance):
        '''
        Removes all points inside maxDistance of the candidate point
        @attention: Unlike matlab candPoint is passed as a structure
        where pos-field is needed.
        '''

        # get 2nd dimension of locVec
        num = locVec.shape[1]
        pos = candPoint.pos[:, np.newaxis]
        dist = (pos * np.ones((3, num))) - locVec
        pointsOutside = (sum(dist * dist) > (maxDistance * maxDistance))

        locVec = locVec[:, pointsOutside]
        probVec = probVec[:, pointsOutside]

        return probVec, locVec


class CandidatePoint(object):
    '''
    Used to represent the candidate points
    '''

    def __init__(self, prob, locVec):
        self.inrange = np.array([False], dtype=bool)
        self.prob = prob
        self.pos = locVec


class Result(object):
    '''
    Used to represent the formatted results structure
    in MATLAB.
    '''

    def __init__(self, smallClasses, maxDistances):
        self.methodResults = dict()
        self.maxDistances = maxDistances
        self.classes = smallClasses
