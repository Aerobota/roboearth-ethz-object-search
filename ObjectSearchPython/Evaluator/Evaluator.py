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

    def __init__(self,params):
        '''    
        Constructor. Not used.
        '''
        pass

class LocationEvaluator(Evaluator):
    '''
    Master Class for Evaluating Location Models
    This class implements the EVALUATE method and supplies 
    the two static methods PROBABILITYVECTOR and GETCANDIDATEPOINTS.
    '''
    
    def evaluate(self,testData,locationLearner,evaluationMethods,maxDistances):
        '''
        This method evaluates LOCATIONLEARNER on the TESTDATA using
        the EVALUATIONMETHODS and MAXDISTANCES. The returned RESULT
        is structure that contains data to be consumed by the
        appropriate EVALUATION.EVALUATIONDATA.
        '''
        
        # get the small classes
        classesSmall = testData.getSmallClassNames()
        # all results will be stored in this dictionary
        resultsCollector = dict()
        
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
            
            
    def getOccurringClassesAndObjects(self, testData, image):
        '''
        Check which objects actually occur in this scene and remove
        all classes that have no object in the scene. 
        
        Save all objects of the small classes in smallObjects
        as a dictionary of small classes.
        '''
        
        classesSmall = testData.getSmallClassNames()
        
        # get numpy array of structs, each struct corresponding to one object
        objs = testData.getObjectMAT(image)
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
        
        LOCATIONLEARNER is an implementation of a LearnFunc.LocationLearner.
        
        SMALLOBJECTS is a dictionary with keys consisting of the names
        of the small classes for which output is to be generated.
        
        PROBVEC is a dictionary with keys same as SMALLOBJECTS
        where every entry is a vector of probabilities
        for every point in the cloud.
        
        LOCVEC is a 3xn numpy array where each column is the 3D-position of
        a point of the cloud.
        '''
        evidence = locationLearner.evidenceGenerator.getEvidenceForImage(data, image)
        