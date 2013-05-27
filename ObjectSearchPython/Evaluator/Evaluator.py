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
        '''
        
        # get the small classes
        classesSmall = testData.getSmallClassNames()
        # all results will be stored in this dictionary
        results = dict()
        
        for image in testData.data:
            print "Collecting data for image", image.filename
            # For the current image get all small classes in this image
            # and all the objects belonging to these classes
            smallObjects = self.getOccurringClassesAndObjects(testData,image)
            # if there are small objects in the image
            if len(smallObjects) != 0:
                # Get the probability distribution over the scenes
                # point cloud and the location of each point in the cloud.
                probVec, locVec = self.probabilityVector(testData, image, locationLearner, smallObjects)
                for c in probVec.iterkeys(): # for each small object
                    for d in range(len(self.maxDistances)):
                        # generate candidate points and evaluate them
                        pass #TODO:
                        for e in range(len(self.evalMethod)):
                            # for each evaluation method compute the score
                            pass #TODO:
                        
            
        # TODO: Reformat the result dictionary and pickle
            
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
        
        TODO: Does it work? Why are we taking a mean?
        '''
        evidence = locationLearner.evidenceGenerator.getEvidenceForImage(data, image)
        
        probVec = dict(dict())
        # For each (small object) class and observed object 
        # compute the pairwise probability
        for c in smallObjects.iterkeys(): # for each small object
            try:
                for idx_o in range(evidence['relEvidence'].shape[0]): # for each (observed) large object
                    o = evidence['names'][idx_o]
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
        