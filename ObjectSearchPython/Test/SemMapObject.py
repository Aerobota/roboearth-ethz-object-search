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