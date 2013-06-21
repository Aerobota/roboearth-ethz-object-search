'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

import numpy as np

class Evaluator(object):
    '''
    Base class for evaluators
    This is the common base class for all classes evaluating a learned
    model.
    '''
    nThresh = 100

    def __init__(self,maxDistList,evaluationMethod):
        '''    
        Constructor. 
        @attention: Unlike MATLAB version, used to set the maximum distances d_max
        and the evaluation methods.
        '''
        #maximum distances d_max
        #inside which the location predictor gets a positive score
        self.maxDistances = maxDistList
        self.evalMethod = evaluationMethod
        

class LocationEvaluator(Evaluator):
    '''
    Master Class for Evaluating Location Models
    This class implements the EVALUATE method and supplies 
    the two static methods PROBABILITYVECTOR and GETCANDIDATEPOINTS.
    '''
    
    def evaluate(self,testData,locationLearner):
        '''
        This method evaluates LOCATIONLEARNER on the TESTDATA using
        the EVALUATIONMETHODS and MAXDISTANCES. The returned RESULT
        is structure that contains data to be consumed by the
        appropriate EVALUATION.EVALUATIONDATA.
        
        @attention: Unlike MATLAB, we're not running a parallel loop
        here so no need to keep track of extra stuff.
        '''
        
        # get the small classes
        classesSmall = testData.getSmallClassNames()
        
        # all results will be stored in this dictionary
        results = dict()
        
        for method in self.evalMethod:
        # for each evaluation method compute the score
            results[method] = dict()
            for maxDistance in self.maxDistances:
                results[method][maxDistance] = dict()
                for image in testData.data:
                    results[method][maxDistance][image] = dict()
                    print "Collecting data for image", image.filename
                    # For the current image get all small classes in this image
                    # and all the objects belonging to these classes
                    smallObjects = self.getOccurringClassesAndObjects(testData,image)
                    # if there are small objects in the image
                    if len(smallObjects) != 0:
                        # Get the probability distribution over the scenes'
                        # point cloud and the location of each point in the cloud.
                        probVec, locVec = self.probabilityVector(testData, image, locationLearner, smallObjects)
                        for c in smallObjects.iterkeys(): # for each small object
                            # matrix of column stacked 3d positions
                            truePos = locationLearner.evidenceGenerator.getPositionEvidence(smallObjects[c])
                            # generate candidate points and evaluate them
                            candidatePoints = self.getCandidatePoints(probVec[c], locVec, truePos, maxDistance)
                            results[method][maxDistance][image][c] = method.scoreClass(candidatePoints)
                            
        # format the results
        out = Result(classesSmall,self.maxDistances)
        for method in self.evalMethod:
            out.methodResults[method.designation] = list()
            for maxDistance in self.maxDistances:
                inp = method.combineResults(results[method][maxDistance], classesSmall)
                out.methodResults[method.designation].append(inp)
          
        return out  
        
            
    def getOccurringClassesAndObjects(self, testData, image):
        '''
        Check which objects actually occur in this scene and remove
        all classes that have no object in the scene. 
        
        Save all objects of the small classes in smallObjects
        as a dictionary of small classes.
        '''
        
        classesSmall = testData.getSmallClassNames()
        
        # get numpy array of structs, each struct corresponding to one object
        objs = testData.loadObjectMAT(image)
        names = testData.getNamesOfObjects(objs)
        
        #TODO: seems to be working!
        smallObjects = dict()
        # use for indexing
        namesArray = np.array(names)
        
        for c in classesSmall:
            if names.count(c):
                smallObjects[c] = objs[namesArray == c]
        
        return smallObjects
    
    def probabilityVector(self, data, image, locationLearner, smallObjects):
        '''
        [PROBVEC,LOCVEC] = PROBABILITYVECTOR(DATA,IMAGE,LOCLEARNER,SMALLOBJ)
        Returns the probability of each point in the scenes point
        cloud and the position of each point.
        
        DATA is an implementation of a DataHandlers.DataStructure
        containing the test data.
        
        IMAGE is the desired scene.
        
        LOCATIONLEARNER is an implementation of a Learner.LocationLearner.
        
        SMALLOBJECTS is a dictionary with keys consisting of the names
        of the small classes for which output is to be generated.
        
        PROBVEC is a dictionary of dictionaries 
        with keys same as SMALLOBJECTS and OBSERVED OBJECTS
        where every entry is a vector of probabilities for every point in the cloud.
        
        LOCVEC is a 3xn numpy array where each column is the 3D-position of
        a point of the cloud.
        
        TODO: Does it work? 
        '''
        
        evidence = locationLearner.evidenceGenerator.getEvidenceForImage(data, image)
        
        probVec = dict()
        # For each (small object) class and observed object 
        # compute the pairwise probability
        for c in smallObjects.iterkeys(): # for each small object
            try:
                probVec[c] = dict()
                for idx_o in range(evidence['relEvidence'].shape[0]): # for each (observed) large object
                    o = evidence['names'][idx_o]
                    # each row in mat should correspond to a single data point
                    mat = np.squeeze(evidence['relEvidence'][idx_o,:,:])
                    probVec[c][o] = locationLearner.getProbabilityFromEvidence(mat,o,c)
                # Compute the mean of the pairwise probabilities
                probVec[c]['mean'] = np.sum(probVec[c].values(),0)/len(probVec[c].values())
            except KeyError:
                print 'Nonexistent class!'
                # make a uniform distribution
                size = evidence['absEvidence'].shape[1]
                probVec[c]['mean'] = 1/size * np.ones((1,size))
            
        
        # the absolute locations were returned with the evidence dictionary
        locVec = evidence['absEvidence']        
        return probVec, locVec
      
    def getCandidatePoints(self, probVec, locVec, truePos, maxDistance):
        '''
        [INRANGE,CANDIDATEPROB,CANDIDATEPOINTS]=GETCANDIDATEPOINTS(PROBVEC,LOCVEC,TRUEPOS,MAXDISTANCE)
        Generates candidatePoints and computes if they are inside a
        maximal distance to any groundtruth object of the correct
        class.
        
        PROBVEC is a single field(i.e. class) from the struct returned
        by Evaluator.LocationEvaluator.probabilityVector.
        
        LOCVEC is the array of the same name returned as well by 
        Evaluator.LocationEvaluator.probabilityVector.
        
        TRUEPOS is the real 3D-location of the ground truth objects.
        
        MAXDISTANCE is the scalar maximum distance in metres that a
        candidate point can have to a ground truth object and be
        counted as inRange.
        
        RETURNS a list of CANDIDATEPOINT structure where:
        
        INRANGE is a boolean n-vector that denotes if candidate
        point m is inside MAXDISTANCE to ground truth object n.
        
        CANDIDATEPROB denotes the probability of each
        candidate point.
        
        CANDIDATEPOS is a 3-vector showing position of the candidate point
        
        See also EVALUATOR.LOCATIONEVALUATOR.PROBABILITYVECTOR
        
        TODO: check to see if it works!
        @attention: Unlike MATLAB code, here running a for loop to 
        calculate range for candidate points
        '''
        
        # sort the point cloud by decreasing probability
        probs = probVec['mean']
        ind = probs.argsort()
        locVec = locVec[:,ind]
        
        # list of candidate points
        candidatePoints = list()
        while locVec.shape[1] is not 0:
            # Fit a candidate point to the location of highest
            # probability
            newCand = CandidatePoint(probs[0], locVec[:,0])
            candidatePoints.append(newCand)
            # Remove all cloud points in range of the new point
            probs, locVec = self.removeCoveredPoints(probs, locVec, newCand, maxDistance)
        
        if truePos.shape[1] is not 0:
            n = truePos.shape[1]
            # Check which candidate points are in range of ground truth
            # objects            
            for cand in candidatePoints:
                dist = (cand.pos * np.ones((3,n))) - truePos
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
        pos = candPoint.pos[:,np.newaxis]
        dist = (pos * np.ones((3,num))) - locVec
        pointsOutside = (sum(dist * dist) > (maxDistance * maxDistance))
        
        locVec = locVec[:,pointsOutside]
        probVec = probVec[:,pointsOutside]
        
        return probVec, locVec

class CandidatePoint(object):
    '''
    Used to represent the candidate points
    '''
    
    def __init__(self, prob, locVec):
        self.inrange = np.array([False], dtype = bool)                  
        self.prob = prob
        self.pos = locVec
        
class Result(object):
    '''
    Used to represent the formatted results structure
    in MATLAB.
    '''
    
    def __init__(self,smallClasses,maxDistances):
        self.methodResults = dict()
        self.maxDistances = maxDistances
        self.classes = smallClasses