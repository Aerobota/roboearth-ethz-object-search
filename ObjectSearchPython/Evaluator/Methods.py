'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

class LocationEvaluationMethod(object):
    '''
    Abstract Location Evaluation Method
    This is an interface for methods to evaluate the location
    performance.
    '''
    #The number of desired data points
    nThresh = 100

    def __init__(self,params):
        '''
        Constructor. Doesn't do anything.
        '''
        pass
        
class FROCLocationEvaluator(LocationEvaluationMethod):
    '''
    Free-Response Receiver Operating Characteristic
    This can be used to gather the information used to plot free-response
    receiver operating characteristics results. This is a
    LOCATIONEVALUATIONMETHOD and is used in conjunction with the
    LOCATIONEVALUATOR.
    '''
    designation = 'FROC'



class FirstNLocationEvaluator(LocationEvaluationMethod):
    '''
    Evaluation method for the search task
    This can be used to gather the information used to plot search task
    results. This is a LOCATIONEVALUATIONMETHOD and is used in
    conjunction with the LOCATIONEVALUATOR.
    '''
    designation = 'FirstN'

   