'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

import os.path
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
    objectTag = 'obj_' # TODO: Ever required?
    depthFolder = 'depth/'

    # Dummy fields - Have to be overwritten to use the DataStructure
    trainSet = ''
    testSet = ''

    def __init__(self, path, testOrTrain):
        '''
        Construct an empty dataset container. The data will be
        loaded from or saved in the folder specified by PATH.
        TESTORTRAIN is a string containing 'test' or 'train'
        depending on which part of the dataset should be loaded.

        The container is empty needs to be loaded using OBJ.LOAD().
        '''

        # make sure testOrTrain is 'test' or 'train'
        if testOrTrain not in ['test', 'train']:
            raise ValueError("The testOrTrain argument must be ''test'' or ''train''.")

        # generate preallocated data structure
        self.data = None

        self.path = path

        if testOrTrain == 'train':
            assert self.trainSet, "Field 'trainSet' has to be set"
            self.storageName = self.trainSet
        else:
            assert self.testSet, "Field 'testSet' has to be set"
            self.storageName = self.testSet

        # initialize classes
        self.classes = []
        self.classesLarge = []
        self.classesSmall = []

    def getClassNames(self):
        '''
        Returns the class names as a numpy array of unicode strings.
        '''
        if not self.classes:
            self.loadClassesMAT()

        return self.classes

    def getSmallClassNames(self):
        '''
        Returns the small class names as a numpy array of
        unicode strings.
        '''
        if not self.classesSmall:
            self.loadClassesMAT()

        return self.classesSmall

    def getLargeClassNames(self):
        '''
        Returns the large class names as a numpy array of
        unicode strings.

        TODO: Static methods should be used sparingly!
        '''
        if not self.classesLarge:
            self.loadClassesMAT()

        return self.classesLarge

    def loadDataMAT(self):
        '''
        Load the stored MAT file as a numpy array of Data objects.
        '''
        filename = os.path.join(self.path, self.storageName)

        try:
            mat = sio.loadmat(filename, appendmat=True, squeeze_me=True)
        except IOError:
            print 'File does not exist:', filename
            raise

        self.data = mat['data']

    def loadClassesMAT(self):
        '''
        Load the classes from MAT file given by catFileName field
        as a numpy array of strings.
        '''
        filename = os.path.join(self.path, self.catFileName)

        try:
            mat = sio.loadmat(filename, squeeze_me=True, appendmat=True)
            self.classes = list(str(name) for name in mat['names'])
            self.classesSmall = list(str(name) for name in mat['smallNames'])
            self.classesLarge = list(str(name) for name in mat['largeNames'])
        except IOError:
            print 'File does not exist:', filename
            raise

    def loadObjectMAT(self, image):
        '''
        Loads the objects mat file associated with the particular image
        Has to modify the objectPath since the structure objects are now
        stored in /objectPython and not in /object.

        Returns an array of structs, each containing information about an
        object in the image.
        '''
        modifiedObjectPath = str(image['objectPath']).replace('object/', self.objectFolder)
        filename = os.path.join(self.path, modifiedObjectPath)

        try:
            mat = sio.loadmat(filename, squeeze_me=True)
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
        filename = os.path.join(self.path, self.depthFolder, str(image['depthname']))

        try:
            mat = sio.loadmat(filename, squeeze_me=True)
        except IOError:
            print 'File does not exist:', filename
            raise

        # return the 2D numpy array
        return mat['depth']


    def getNamesOfObjects(self, objs):
        '''
        Returns the names of each object in the image
        as a list of strings
        '''
        return list(str(obj['name']) for obj in objs)

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
        nX = np.arange(1, depthSizeX + 1)
        nY = np.arange(1, depthSizeY + 1)
        X, Y = np.meshgrid(nX, nY)
        # total number of elements
        numTot = np.size(X)

        # Generate 2D homogeneous coordinates
        pos = np.vstack((X.ravel(), Y.ravel(), np.ones((numTot,))))
        # bug with lapack
        pos.newbyteorder('=')

        # Get the calibration matrix
        calibM = image['calib'].newbyteorder('=')

        # Apply calibration matrix to get normalized 2D coordinates
        pos = np.linalg.lstsq(calibM, pos)[0]

        # Scale every dimension by the depth to get 3D
        for d in range(3):
            pos[d, :] = pos[d, :] * depthImage.transpose().ravel()

        return pos


class NYUDataStructure(DataStructure):
    '''
    Implementation of DATAHANDLER.DATASTRUCTURE
    This class implements the abstract class DATAHANDLER.DATASTRUCTURE
    for data generated with DATAHANDLER.CONVERTFROMNYUDATASET. (This
    is not implemented in Python since it needs to be called only once
    in MATLAB)
    '''
    imageFolder = 'image' # TODO: Ever required?
    catFileName = 'objectCategories' # TODO: Ever required?
    testSet = 'groundTruthTest'
    trainSet = 'groundTruthTrain'


class Box(object):
    '''
    Box is a class that can generate
    a mesh for the semantic map.
    '''
    _mesh = []

    def __init__(self, mins, maxs, delta):
        '''
        Constructor for the box.
        Mins: Array containing xmin,ymin,zmin values
        Maxs: Array containing xmax,ymax,zmax values
        Delta: Distance between each point in grid.
        '''

        x = np.arange(mins[0], maxs[0] + delta, delta)
        y = np.arange(mins[1], maxs[1] + delta, delta)
        z = np.arange(mins[2], maxs[2] + delta, delta)

        self._mesh = self.cartesian([x, y, z])

    def getMesh(self):
        '''
        Returns mesh as 3xn array.
        '''

        return self._mesh.transpose()


    def cartesian(self, arrays, out=None):
        """
        Generate a cartesian product of input arrays.
        TODO: replace with np.mgrid for mesh generation.

        Parameters
        ----------
        arrays : 1-D numpy arrays to form the cartesian product of.
        out : ndarray
            Array to place the cartesian product in.

        Returns
        -------
        out : ndarray
            2-D array of shape (M, len(arrays)) containing cartesian products
            formed of input arrays.

        Examples
        --------
        >>> cartesian(([1, 2, 3], [4, 5], [6, 7]))
        array([[1, 4, 6],
               [1, 4, 7],
               [1, 5, 6],
               [1, 5, 7],
               [2, 4, 6],
               [2, 4, 7],
               [2, 5, 6],
               [2, 5, 7],
               [3, 4, 6],
               [3, 4, 7],
               [3, 5, 6],
               [3, 5, 7]])

        @snippet Code taken from:
        http://stackoverflow.com/questions/1208118/using-numpy-to-build-an-array-of-all-combinations-of-two-arrays
        """

        dtype = arrays[0].dtype

        n = np.prod([x.size for x in arrays])
        if out is None:
            out = np.zeros([n, len(arrays)], dtype=dtype)

        m = n / arrays[0].size
        out[:, 0] = np.repeat(arrays[0], m)
        if arrays[1:]:
            self.cartesian(arrays[1:], out=out[0:m, 1:])
            for j in xrange(1, arrays[0].size):
                out[j * m:(j + 1) * m, 1:] = out[0:m, 1:]

        return out


class SmallObject(object):
    '''
    Temporary class for a small object queried for.
    In the case of learning from one sample scenario,
    the location field has to be specified also.

    '''

    def __init__(self, name, loc=None):
        '''
        Initializes fields of the smallObject.
        '''

        self.type = name
        if loc is not None:
            # set also the location
            self.loc = loc
