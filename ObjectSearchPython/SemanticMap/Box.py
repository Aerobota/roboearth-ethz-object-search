'''
Created on Aug 14, 2013.
Mesh for the semantic map containing objects.

@author: okan
'''

import numpy as np

class Box(object):
    '''
    Box is a class that can generate
    a mesh for the semantic map.
    '''
    _mesh = []

    def __init__(self,mins,maxs,delta):
        '''
        Constructor for the box.
        Mins: Array containing xmin,ymin,zmin values
        Maxs: Array containing xmax,ymax,zmax values
        Delta: Distance between each point in grid.
        '''
        
        x = np.arange(mins[0],maxs[0] + delta,delta)
        y = np.arange(mins[1],maxs[1] + delta,delta)
        z = np.arange(mins[2],maxs[2] + delta,delta)
        
        self._mesh = self.cartesian([x,y,z])
        
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
        out[:,0] = np.repeat(arrays[0], m)
        if arrays[1:]:
            self.cartesian(arrays[1:], out = out[0:m,1:])
            for j in xrange(1, arrays[0].size):
                out[j*m:(j+1)*m,1:] = out[0:m,1:]
                
        return out
        
        