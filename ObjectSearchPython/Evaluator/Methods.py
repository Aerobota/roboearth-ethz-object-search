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

    def __init__(self):
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
    
    def scoreClass(self, candidatePoints):
        '''
        CandidatePoints is a list of CandidatePoint structure.        
        Saves the results and returns as a results structure.
        
        '''
        
        result = ResultFROC()
        
        # only the first detections are true detections (true pos.)
        pts = list(candidatePoints)
        # TODO: find a better way to implement!
        for i,pt in enumerate(pts):
            # find the column indices that are true
            # those column indices will be false in future columns
            for j in range(i+1,len(pts)):
                pts[j].inrange[pt.inrange] = False
            
        # save the number of true positives
        # save the probability of the candidate points
        result.tp = []
        result.pointProb = []
        for pt in pts:
            result.tp.append(sum(pt.inrange))
            result.pointProb.append(pt.prob)
        
        # save the number of ground-truth sought objects
        result.pos = len(candidatePoints[0].inrange)
        
        return result
    
    def combineResults(self, collectedResults, classesSmall):
        '''
        Combines the results collected by scoreClass method.
        '''
        pass #TODO:


class FirstNLocationEvaluator(LocationEvaluationMethod):
    '''
    Evaluation method for the search task
    This can be used to gather the information used to plot search task
    results. This is a LOCATIONEVALUATIONMETHOD and is used in
    conjunction with the LOCATIONEVALUATOR.
    '''
    designation = 'FirstN'
    
    def scoreClass(self, candidatePoints):
        '''
        Candidate points is a list of CandidatePoint structure.
        
        Returns results as an integer.
        '''
        
        # Get the index of the first candidate point that is in range        
        result = float('Inf')
        for i,candidatePoint in enumerate(candidatePoints):
            if any(candidatePoint.inrange):
                result = i + 1
                break               
                
        return result
    
    def combineResults(self, collectedResults, classesSmall):
        '''
        For every class, finds all unique data points and makes a
        count of the occurrence of each data point
        
        TODO: is it correct? Unlike MATLAB, no way to concatenate 
        variable number of arguments [MATLAB uses cells to do this].
        '''
        pass #TODO:
        


class ResultFROC(object):
    '''
    Used to represent the structure that is returned
    by scoreClass in FROCLocationEvaluator class.
    '''
    
    def __init__(self):
        
        self.pos = False # number of ground truth sought objects
        self.neg = True
        self.pointProb = list() # probability of candidate point
        self.tp = list() #True positives   
        self.names = list() # small classes sought for