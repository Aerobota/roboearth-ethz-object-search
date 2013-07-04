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
    '''

    def __init__(self):
        '''
        Doesn't do anything.
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
        # initialize evidence entries to hold numpy arrays
        for i in range(len(classes)):
            for j in range(i,len(classes)):
                #TODO: not recommended for numpy!
                evidence[(str(classes[i]), str(classes[j]))] = np.zeros((0,2)) 
        
        # go through each room scanning for evidence
        for image in dataStr.data:
            objs = dataStr.loadObjectMAT(image)
            pos = self.getPositionEvidence(objs) 
            relEvidence = self.getRelativeEvidence(pos,pos)
            names = dataStr.getNamesOfObjects(objs)
            
            #storing also the distance of small-small and large-large object occurrences       
            for i in range(len(names)):
                for j in range(i+1,len(names)):
                    try:
                        evidence[(names[i], names[j])] = \
                        np.vstack((evidence[(names[i], names[j])],relEvidence[i,j,:]))
                    except KeyError:
                        evidence[(names[j], names[i])] = \
                        np.vstack((evidence[(names[j], names[i])],relEvidence[i,j,:]))
        
        return evidence 
    
    def getEvidenceForImage(self, dataStr, image):
        '''
        Produces relative location evidence for all pixels in a
        single scene.
        Observed objects: Large classes
        
        DATASTR is the test dataset.
        
        IMAGE is the desired scene.
        
        EVIDENCE is a dictionary with three keys:
        'names': the class names of the observed objects
        'absEvidence': the 3D-location of every pixel
        'relEvidence': the relative location from every observed object
        to every pixel
        '''  
        
        objs = dataStr.loadObjectMAT(image)
        names = dataStr.getNamesOfObjects(objs)
        classesLarge = dataStr.getLargeClassNames()
        
        evidence = dict()
        evidence['names'] = list()
        
        pos = self.getPositionEvidence(objs)
        
        idx = list()
        # TODO: does the indexing work ? think of a better way perhaps!
        for i, c in enumerate(names):
            if c in classesLarge:
                idx.append(i)
                evidence['names'].append(c)
                
        # positions of large objects
        objPos = np.zeros((3,len(idx)))          
        for i, val in idx:
            objPos[:,i] = pos[:,val]
        
        evidence['absEvidence'] = self.getPositionForImage(dataStr, image)
        evidence['relEvidence'] = self.getRelativeEvidence(objPos, evidence['absEvidence'])
        
        return evidence
            
class CylindricalEvidenceGenerator(LocationEvidenceGenerator):
    '''
    Produces relative locations in cylindrical coordinates
    This class implements Learner.LocationEvidenceGenerator. The
    returned evidence is 2-dimensional where the first dimension is the
    horizontal distance and the second the height.
    '''
    
    def getPositionEvidence(self, objs):
        '''
        Return the positions of each object in the image
        as a matrix of column stacked 3d-positions.
        '''
        
        mat = np.zeros((3,len(objs)))
        for i,obj in enumerate(objs):
            mat[:,i] = obj['pos']
        
        return mat    
    
    def getPositionForImage(self, dataStr, image):
        '''
        Returns the 3d-positions (3D location of every pixel)
        of the point cloud corresponding to the image.
        
        Just a wrapper for DataStructure.get3DPositionsForImage(image).
        '''    
        return dataStr.get3DPositionForImage(image)
    
    
    def getRelativeEvidence(self, sourcePos, targetPos):
        '''
        Returns cylindrical evidence as a 3D-array of 
        1. Object-to-object distance matrix in xz-coordinates (radius)
        2. Object-to-object matrix of vertical distances (y).     
        '''
        
        # initialize dist array
        num_source_obj = np.shape(sourcePos)[1]
        num_target_obj = np.shape(targetPos)[1]
        dist = np.zeros((num_source_obj, num_target_obj, 3))
        evidence = np.zeros((num_source_obj, num_target_obj, 2))

        # Broadcasting vec here
        for d in range(3):
            vec = targetPos[d,:]
            mat = sourcePos[d,:] - vec[:,np.newaxis]
            dist[:,:,d] = mat
        
        # apparently the first row is the row of vertical distances (y)
        evidence[:,:,0] = dist[:,:,0]
        evidence[:,:,1] = np.sqrt(dist[:,:,1]**2 + dist[:,:,2]**2)
        
        return evidence
        
        
        