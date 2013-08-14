#!/usr/bin/env python
'''
Created on July 29, 2013

This scenario investigates the use of inference in learned models.
@author: okankoc

TODO:
1. Build a dictionary relating object classes to definitions in knowrob.url
2. Receive a semantic map and parse it.
3. Integrate with ROS.

'''

from SemanticMap.SemMap import SemMap, SemMapObject, SmallObject
from Learner import EvidenceGenerator, Learner
from Evaluator import Evaluator

## Create a semantic map
print 'Creating a basic semantic map...'
semMap = SemMap()
semMap.header.frame_id = "http://www.example.com/foo.owl#"
semMap.header.stamp = 0

#create object - cabinet
obj1 = SemMapObject()
obj1.id = 1
obj1.partOf = 0
obj1.type = 'cabinet'
obj1.loc = [0.0, 0.0, 0.0]
obj1.depth = 1
obj1.width = 1
obj1.height = 1

#create object - bed
obj2 = SemMapObject()
obj2.id = 1
obj2.partOf = 0
obj2.type = 'bed'
obj2.loc = [0.5, 0.5, 0.5]
obj2.depth = 1
obj2.width = 1
obj2.height = 1


obj1.pose = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
obj2.pose = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
semMap.objects.append(obj1)
semMap.objects.append(obj2)

#small objects to query for
smallObjs = []
smallObjs.append(SmallObject('bottle'))

## Query for candidate points
maxDist = 1.0
# the amount by which the mesh is stretched
stretch = 0.5
# fineness of the grid, in terms of meters
gridResolution = 0.05 

# TODO: make sure the whole dataset is learned

# load the pickled GMM Models
locCylinder = EvidenceGenerator.CylindricalEvidenceGenerator(stretch,gridResolution)
locGMM = Learner.ContinuousGMMLearner(locCylinder)
locGMM.load()

evalBase = Evaluator.LocationEvaluator(maxDist, [])
candPoints = evalBase.infer(semMap, smallObjs, locGMM, maxDist)

# print candidate point locations
for candPoint in candPoints:
    print 'Location for candidate point:', candPoint.pos
