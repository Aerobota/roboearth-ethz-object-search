'''
Created on July 29, 2013

This scenario investigates the use of inference in learned models.
@author: okankoc

TODO:
1. Build a dictionary relating object classes to definitions in knowrob.url
2. Receive a semantic map and parse it.
3. Infer the location of searched object (candidatePoints)
4. Send the most likely location back.

'''

#!/usr/bin/env python
from . import SemMap
from . import SemMapObject
from Learner import EvidenceGenerator, Learner
from Evaluator import Evaluator
 
# Create a semantic map
print 'Creating a basic semantic map...'
semMap = SemMap()
semMap.header.frame_id = "http://www.example.com/foo.owl#"
semMap.header.stamp = 0
    
#create object - cabinet
obj1 = SemMapObject()
obj1.id = 1
obj1.partOf = 0
obj1.type = 'cabinet'
obj1.loc = [0.0,0.0,0.0]
obj1.depth = 1
obj1.width = 1
obj1.height = 1

obj1.pose = [1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0]
semMap.objects.append(obj1)

#small objects to query for
smallObj = ['bottle']

# load the pickled GMM Models
locCylinder = EvidenceGenerator.CylindricalEvidenceGenerator()
locGMM = Learner.ContinuousGMMLearner(locCylinder)
locGMM.load()

# Query for candidate points        
maxDist = 1.5
candPoints = Evaluator.infer(semMap,smallObj,locGMM,maxDist)