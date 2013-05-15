'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''
class Learner(object):
    '''
    Base class for all learners
    Defines a few commonalities between the learner classes.
    '''
    
    minSamples = 20

    def __init__(self,evidenceGenerator):
        '''
        OBJ=LEARNER(EVIDENCEGENERATOR)
        The standard constructor for all learner classes. An evidence
        generator is always necessary and is assigned during construction.
        '''
        self.evidenceGenerator = evidenceGenerator
        
class LocationLearner(Learner):
    '''
    Base class for location learning
    Extends the basic Learner.Learner interface. Especially adds two
    methods: getProbabilityFromEvidence, removeParents.
    '''
    

class ContinuousGMMLearner(LocationLearner):
    '''
    Models relative location as a mixture of Gaussian
    This method a used to learn a mixture of Gaussians model of the
    distribution of relative locations between object pairs.
    '''
    
    maxComponents = 5
    
    def learn(self, dataStr):
        '''
        Learns the GMM probabilities.
        '''
        
        #Get the relative location samples
        samples = self.evidenceGenerator.getEvidence(dataStr)