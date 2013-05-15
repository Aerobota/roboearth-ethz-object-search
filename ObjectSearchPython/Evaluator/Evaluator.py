'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

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
    This class implements the EVALUATE method from the abstract
    EVALUATOR class and supplies the two static methods
    PROBABILITYVECTOR and GETCANDIDATEPOINTS.
    '''
    
        