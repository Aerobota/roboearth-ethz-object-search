import numpy as np

class SemMap(object):
    '''
    Temporary class for a semantic map.
    '''
    
    def __init__(self):
        '''
        Semantic map message type, Moritz Tenorth, tenorth@cs.tum.edu
        '''
        self.header = Header()
        self.objects = list() # List of objects in the map

class Header(object):
    '''
    Temporary class for a semantic map header.
    '''
    
    def __init__(self):
        '''
        Initialize header fields.
        '''
        self.frame_id = ""
        self.stamp = 0
        
class SemMapObject(object):
    '''
    Temporary class for an object stored in 
    a semantic map.
    '''
    
    def __init__(self):
        '''
        Initialize fields of the object.
        '''
        self.id = 0
        self.partOf = ''
        self.type = ''
        self.loc = [0.0,0.0,0.0]
        self.depth = 0
        self.width = 0
        self.height = 0

        self.pose = [1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0]