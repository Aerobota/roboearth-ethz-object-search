'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

class DataStructure(object):
    '''
    Abstract class that stores a dataset
    This class is a container for arbitrary datasets than can be
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
    property, most methods in EVALUATION and LEARNFUNC should work
    with the derived data structure.
    
    For example implementation see DATAHANDLERS.NYUDATASTRUCTURE.
    '''
    
    objectFolder='object'
    objectTag='obj_'
    depthFolder='depth'


    def __init__(self,path,testOrTrain):
        '''
        Construct an empty dataset container. The data will be
        loaded from or saved in the folder specified by PATH.
        TESTORTRAIN is a string containing 'test' or 'train'
        depending on which part of the dataset should be loaded.
        
        The container is empty needs to be loaded using OBJ.LOAD().
        '''
        
        # make sure testOrTrain is 'test' or 'train'
        if testOrTrain is not 'test' or testOrTrain is not 'train':
            raise Exception("The testOrTrain argument must be ''test'' or ''train''.'")
        
        # generate preallocated data structure
        data = Data()
        data.filename = ""                        
        data.depthname = ""
        data.folder = ""
        data.imagesize = []
        data.calib = []
        data.objectPath = ""
        
        self.path = path
        self.setChooser = testOrTrain
        self.storageName = self.storageName()
        

class NYUDataStructure(DataStructure):
    '''
    Implementation of DATAHANDLERS.DATASTRUCTURE
    This class implements the abstract class DATAHANDLERS.DATASTRUCTURE
    for data generated with DATAHANDLERS.CONVERTFROMNYUDATASET.
    '''

    imageFolder='image'
    catFileName='objectCategories.mat'
    testSet='groundTruthTest'
    trainSet='groundTruthTrain'
        
class Data(object):
    '''
    Used to represent a structure (MATLAB compatibility)
    '''
    pass