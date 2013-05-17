'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

import numpy as np

class EvidenceGenerator(object):
    '''
    Abstract base class
    This base class exists only for structure. 
    
    @attention: I have added getNamesOfObjects method as a utility function. 
    This was not required in matlab since you can ask for fields of an array
    of structs directly there.
    '''

    def __init__(self):
        '''
        Doesn't do anything
        '''
        pass
    
    def getNamesOfObjects(self, objs):
        '''
        Returns the names of each object in the image
        as a list of strings
        
        TODO: maybe doesn't belong here.
        '''
        s = []
        for obj in objs:
            s.append(obj.name)
        return s
        
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
        
        RETURNS: EVIDENCE is a dictionary where EVIDENCE[(object_i,object_j)] 
        contains the samples from class i to class j. 
        The format of the samples depends on the implementation of 
        GETRELATIVEEVIDENCE in the derived class.
        '''
        
        # numpy array of unicode strings (class names)
        classes = dataStr.getClassNames()
        
        # declare evidence as dictionary 
        # where keys are the object pairs
        evidence = {}
        # initialize evidence entries to hold lists
        for class_i in classes:
            for class_j in classes:
                evidence[(class_i, class_j)] = list()
        
        # go through each room scanning for evidence
        for image in dataStr.data:
            objs = dataStr.getObjectMAT(image)
            pos = self.getPositionEvidence(objs)
            relEvidence = self.getRelativeEvidence(pos,pos)
            names = self.getNamesOfObjects(objs)
            
            #TODO: check to see if working            
            for i in range(len(names)):
                for j in range(i+1,len(names)):
                    evidence[(names[i], names[j])].append(relEvidence[i,j,:].tolist())
                    #evidence[(names[j], names[i])].append(relEvidence[i,j,:].tolist())
        
        return evidence   
            
class CylindricalEvidenceGenerator(LocationEvidenceGenerator):
    '''
    Produces relative locations in cylindrical coordinates
    This class implements LearnFunc.LocationEvidenceGenerator. The
    returned evidence is 2-dimensional where the first dimension is the
    horizontal distance and the second the height.
    '''
    
    def getPositionEvidence(self, objs):
        '''
        Return the positions of each object in the image
        as a matrix of column stacked 3d-positions
        '''
        mat = np.array([[],[],[]])
        for obj in objs:
            mat = np.column_stack(mat, obj.pos)
        
        return mat    
    
    
    def getRelativeEvidence(self, sourcePos, targetPos):
        '''
        Returns cylindrical evidence as a 3D-array of 
        1. 2D-array of distances in xz-coordinates (radius)
        2. 2D-array of vertical distances (y)        
        '''
        
        # initialize dist array
        num_obj = np.shape(sourcePos)[1]
        dist = np.zeros((num_obj, num_obj, 3))
        evidence = np.zeros((num_obj, num_obj, 2))

        for d in reversed(range(3)):
            vec = targetPos[:,d]
            mat = sourcePos[d,:] - vec[:,np.newaxis]
            dist[:,:,d] = mat
        
        # apparently the first row is the row of vertical distances (z)
        evidence[:,:,0] = dist[:,:,0]
        evidence[:,:,1] = np.sqrt(dist[:,:,1]**2 + dist[:,:,2]**2)
        
        return evidence