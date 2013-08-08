class SemMap(object):
    '''
    Temporary class for a semantic map.
    '''
    
    def __init__(self):
        '''
        Semantic map message type, Moritz Tenorth, tenorth@cs.tum.edu
        '''
        self.header = Header()
        self.objects  = list() # List of objects in the map

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