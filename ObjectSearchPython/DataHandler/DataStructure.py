'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

import scipy.io as sio
import numpy as np

class DataStructure(object):
    '''
    Abstract class that stores a dataset
    This class is a container for arbitrary datasets that can be
    converted to its format.
    
    The LOAD and SAVE methods have to be implemented to be able to load
    an arbitrary dataset.
    
    The ADDIMAGE method supplies an interface to convert input data
    into the internal data structure. ADDIMAGE should be used instead
    of writing DATASTRUCTURE.DATA directly. It is allowed to store
    DATASTRUCTURE.DATA to disk using SAVE and retrieve it again during
    LOAD (for an example see DATAHANDLERS.NYUDATASTRUCTURE).
    
    If all abstract methods and properties are correctly implemented in
    a derived class and ADDIMAGE has been used to generate the DATA
    property, most methods in EVALUATOR and LEARNER should work
    with the derived data structure.
    
    For example implementation see DATAHANDLER.NYUDATASTRUCTURE.
    '''
    
    objectFolder = 'objectPython/'
    objectTag = 'obj_'
    depthFolder = 'depth/'


    def __init__(self,path,testOrTrain):
        '''
        Construct an empty dataset container. The data will be
        loaded from or saved in the folder specified by PATH.
        TESTORTRAIN is a string containing 'test' or 'train'
        depending on which part of the dataset should be loaded.
        
        The container is empty needs to be loaded using OBJ.LOAD().
        '''
        
        # make sure testOrTrain is 'test' or 'train'
        if testOrTrain is not 'test' and testOrTrain is not 'train':
            raise Exception("The testOrTrain argument must be ''test'' or ''train''.")
        
        # generate preallocated data structure
        self.data = Data()
        
        self.path = path
        self.setChooser = testOrTrain
        self.storageName = self.getStorageName()
        
        # initialize classes
        self.classes = []
        self.classesLarge = []
        self.classesSmall = []
        
    def getClassNames(self):
        ''' 
        Returns the class names as a numpy array of unicode strings.
        '''
        if len(self.classes) is 0:
            self.loadClassesMAT()
        
        return self.classes
    
    def getSmallClassNames(self):
        '''
        Returns the small class names as a numpy array of 
        unicode strings.
        '''
        if len(self.classes) is 0:
            self.loadClassesMAT()
        
        return self.classesSmall
    
    def getLargeClassNames(self):
        '''
        Returns the large class names as a numpy array of 
        unicode strings.
        '''
        if len(self.classes) is 0:
            self.loadClassesMAT()
        
        return self.classesLarge
    
    def loadClassesMAT(self):
        '''
        Load the classes from MAT file given by catFileName field
        as a numpy array of strings.
        '''
        filename = self.path + self.catFileName
        try:
            mat = sio.loadmat(filename, squeeze_me = True, appendmat = True)
            self.classes = mat['names']
            self.classesLarge = mat['largeNames']
            self.classesSmall = mat['smallNames']
        except IOError:
            print 'File does not exist:', filename
            
    
    def loadObjectMAT(self, image):
        '''
        Loads the objects mat file associated with the particular image
        Has to modify the objectPath since the structure objects are now
        stored in /objectPython and not in /object.
        
        Returns an array of structs, each containing information about an
        object in the image.
        '''
        modifiedObjectPath = str(image['objectPath']).replace('object/', self.objectFolder)
        filename = self.path + modifiedObjectPath
        try:
            mat = sio.loadmat(filename, squeeze_me = True)
        except IOError:
            print 'File does not exist:', filename
            raise
            
        # get array of structs    
        return mat['s']
    
    def loadDepthMAT(self, image):
        '''
        Loads the depth mat file associated with the particular image
        as a 2D numpy array (matrix)
        '''
        filename = self.path + self.depthFolder + image['depthname']
        try:
            mat = sio.loadmat(filename, squeeze_me = True)
        except IOError:
            print 'File does not exist:', filename
            
        # return the 2D numpy array
        return mat['depth']
        
    
    def getNamesOfObjects(self, objs):
        '''
        Returns the names of each object in the image
        as a list of strings
        '''
        s = []
        for obj in objs:
            s.append(str(obj['name']))
        return s
    
    def get3DPositionForImage(self, image):
        '''
        POS = GET3DPOSITIONFORIMAGE(IMAGE)
        POS contains the 3D positions of every pixel of IMAGE.
        POS is a 3xn matrix where n is the total number of
        pixels in the image.
        '''
        
        # Load the depth data
        depthImage = self.loadDepthMAT(image)
        
        # Get the pixel indices
        depthSizeX = depthImage.shape[0]
        depthSizeY = depthImage.shape[1]
        nX = np.arange(1,depthSizeX)
        nY = np.arange(1,depthSizeY)
        X,Y = np.meshgrid(nX, nY)
        # total number of elements
        numTot = np.size(X)        
        
        # Generate 2D homogeneous coordinates
        # TODO: check to see if it produces right answer!
        pos = np.vstack((nX.ravel(), nY.ravel(), np.ones((1,numTot))))
        
        # Get the calibration matrix
        calibM = image.calib
        
        # Apply calibration matrix to get normalized 2D coordinates
        pos = np.linalg.lstsq(calibM, pos)
        
        # TODO: check to see if it produces right answer!
        # Scale every dimension by the depth to get 3D
        for d in range(3):
            pos[d,:] = pos[d,:] * depthImage.transpose().ravel()
        
        return pos
        
class NYUDataStructure(DataStructure):
    '''
    Implementation of DATAHANDLER.DATASTRUCTURE
    This class implements the abstract class DATAHANDLER.DATASTRUCTURE
    for data generated with DATAHANDLER.CONVERTFROMNYUDATASET. (This
    is not implemented in Python since it needs to be called only once
    in MATLAB)
    '''

    imageFolder = 'image'
    catFileName = 'objectCategories'
    testSet = 'groundTruthTest'
    trainSet = 'groundTruthTrain'
    
    def getStorageName(self):
        
        if self.setChooser is 'train':
            return self.trainSet
        else:
            return self.testSet
        
    def loadDataMAT(self):
        '''
        Load the stored MAT file as a numpy array of Data objects.
        '''
        filename = self.path + self.storageName
        try:
            mat = sio.loadmat(filename, appendmat = True, squeeze_me = True)
            matData = mat['data']
        except IOError:
            print 'File does not exist:', filename
            raise 
            
        self.data = matData
            
        
class Data(object):
    '''
    Used to represent the data structure 
    loaded from MATLAB 
    '''
    
    def __init__(self):
        self.filename = ""                        
        self.depthname = ""
        self.folder = ""
        self.imagesize = []
        self.calib = []
        self.objectPath = ""