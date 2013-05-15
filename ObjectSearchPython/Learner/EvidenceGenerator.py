'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''
class EvidenceGenerator(object):
    '''
    Abstract base class
    This base class exists only for structure. It defines the method
    getEvidence but doesn't place any restrictions on input or output
    arguments other than the first and second input arguments.
    '''

    def __init__(self):
        '''
        Doesn't do anything
        '''
        pass
        
class LocationEvidenceGenerator(EvidenceGenerator):
    '''
    Produces location Evidence
    This class is an abstract class that produces evidence of relative
    and absolute locations of objects.
    '''
    
    def getEvidence(self, dataStr):
        '''
        Produces relative location evidence.
        
        DATASTR is a DATAHANDLER.DATASTRUCTURE class instance
        containing the location data.
        
        RETURNS: EVIDENCE is a cxc cell matrix where EVIDENCE{i,j} contains the
                 samples from class i to class j. The format of the samples
                 depends on the implementation of GETRELATIVEEVIDENCE in the
                 derived class.
        '''
        
        # numpy array of unicode strings (class names)
        classes = dataStr.getClassNames()
        
        # go through each room scanning for evidence
        for image in dataStr.data:
            pos = self.getPositionEvidence(dataStr, image)
        
class CylindricalEvidenceGenerator(LocationEvidenceGenerator):
    '''
    Produces relative locations in cylindrical coordinates
    This class implements LearnFunc.LocationEvidenceGenerator. The
    returned evidence is 2-dimensional where the first dimension is the
    horizontal distance and the second the height.
    '''
    
    def getPositionEvidence(self, dataStr, image):
        '''
        Return the position for the image
        '''
        return dataStr.getObjectMAT(image).pos
            