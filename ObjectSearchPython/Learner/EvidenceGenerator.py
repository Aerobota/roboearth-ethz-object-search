'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

import numpy as np
from SemanticMap.Box import Box 

class EvidenceGenerator(object):
    '''
    Abstract base class
    This base class exists only for structure. 
    '''
    largeObjectDefinitionsFile = 'largeObjectDefinitions.txt'

    def __init__(self,epsilon,delta):
        '''
        @change: Adding also initialization for epsilon and delta fields here.
        Epsilon and delta are used for the mesh-generation of the semantic map's
        point cloud.
        '''
        self.epsilon = epsilon
        self.delta = delta
        
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
            for j in range(len(classes)):
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
                for j in range(len(names)):
                    try:
                        evidence[(names[i], names[j])] = \
                        np.vstack((evidence[(names[i], names[j])],relEvidence[i,j,:]))
                    except KeyError:
                        print 'This should not happen!'
                        raise
        
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
        pos = self.getPositionEvidence(objs)
        classesLarge = dataStr.getLargeClassNames()
        
        evidence = dict()
        evidence['names'] = list()
        idx = list()
        
        # TODO: think of a better way!
        for i, c in enumerate(names):
            if c in classesLarge:
                idx.append(i)
                evidence['names'].append(c)
                
        # positions of large objects
        objPos = np.zeros((3,len(idx)))          
        for i, val in enumerate(idx):
            objPos[:,i] = pos[:,val]
        
        evidence['absEvidence'] = self.getPositionForImage(dataStr, image)
        evidence['relEvidence'] = self.getRelativeEvidence(objPos, evidence['absEvidence'])
        
        return evidence
    
    def loadLargeObjectDefinitions(self):
        ''' 
        Loads large objects.
        '''
        f = open(self.largeObjectDefinitionsFile, 'r')
        largeClasses = f.read().splitlines()
        
        #first line is comment
        return largeClasses[1:]
    
    def generateMeshForPointCloud(self, objPos, semMap):
        '''
        Generates a mesh for the partial point cloud of the semantic map
        SEMMAP for which evidence was collected through large objects.
        
        OBJPOS is the 3d-positions of the large objects in the scene.
        
        Generates a box surrounding the large objects where the edges are 
        at least EPSILON meters away from the objects vertices. The mesh is 
        equidistant points inside this cube, each point DELTA away from 
        each other.

        '''
        
        mins = objPos.min(axis = 1) - self.epsilon
        maxs = objPos.max(axis = 1) + self.epsilon
        
        box = Box(mins, maxs, self.delta)
        
        return box.getMesh()
            
        
    def getEvidenceForSemMap(self,semMap,mesh):
        '''
        Produces relative location evidence for the mesh generated for
        the semantic map.
        Observed objects: Large classes
        
        SEMMAP is the semantic map received.
        
        EVIDENCE is a dictionary with two keys:
        'names': the class names of the observed objects
        'absEvidence': the 3D-location of the mesh generated
        'relEvidence': the relative location from every observed object
        to every pixel
        '''  
        
        objs = semMap.objects
        classesLarge = self.loadLargeObjectDefinitions()
        
        evidence = dict()
        evidence['names'] = list()
        idx = list()
        
        # get the types of objects in the semantic map
        for i, c in enumerate(objs):
            if c.type in classesLarge:
                idx.append(i)
                evidence['names'].append(c.type)
                
        # positions of large objects
        objPos = np.zeros((3,len(idx)))          
        for i, val in enumerate(idx):
            objPos[:,i] = np.array(objs[val].loc)
        
        evidence['absEvidence'] = self.generateMeshForPointCloud(objPos, semMap)
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
            mat = vec[:,np.newaxis] - sourcePos[d,:]
            dist[:,:,d] = mat.transpose()
        
        evidence[:,:,0] = np.sqrt(dist[:,:,1]**2 + dist[:,:,2]**2)
        evidence[:,:,1] = dist[:,:,0]
        
        return evidence
        
        
        