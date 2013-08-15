'''
Created on Aug 14, 2013

This scenario investigates the use of one-sample inference.
@author: okankoc

@author: okan

'''

from SemanticMap.SemMap import SemMap, SemMapObject, SmallObject
from Learner import EvidenceGenerator, Learner
from Evaluator import Evaluator

## Create a semantic map
print 'Creating a basic semantic map...'
semMap1 = SemMap()
semMap1.header.frame_id = "http://www.example.com/foo.owl#"
semMap1.header.stamp = 0

#create object - cabinet
obj1 = SemMapObject()
obj1.id = 1
obj1.partOf = 0
obj1.type = 'table'
obj1.loc = [0.0, 0.0, 0.0]
obj1.depth = 1
obj1.width = 1
obj1.height = 1

obj1.pose = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
semMap1.objects.append(obj1)

#small object to learn model of
smallObjs = []
smallObjs.append(SmallObject('serial box', [0.5, 0.4, 0.3]))

maxDist = 1.0
# the amount by which the mesh is stretched
stretch = 0.5
# fineness of the grid, in terms of meters
gridResolution = 0.05 

# load the pickled GMM Models
locCylinder = EvidenceGenerator.CylindricalEvidenceGenerator(stretch,gridResolution)
locGMM = Learner.ContinuousGMMLearner(locCylinder)
locGMM.load('GMMFull')
locGMM.learnFromOneSample(semMap1, smallObjs, 'GMMFull')

## Create a second semantic map
print 'Testing on a second semantic map'
semMap2 = SemMap()
semMap2.header.frame_id = "http://www.example.com/foo.owl#"
semMap2.header.stamp = 0

#create object - cabinet
obj1 = SemMapObject()
obj1.id = 1
obj1.partOf = 0
obj1.type = 'table'
obj1.loc = [0.6, 0.6, 0.6]
obj1.depth = 1
obj1.width = 1
obj1.height = 1

obj1.pose = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
semMap2.objects.append(obj1)

#small object to query for
smallObjs = []
smallObjs.append(SmallObject('serial box'))

evalBase = Evaluator.LocationEvaluator(maxDist, [])
candPoints = evalBase.infer(semMap2, smallObjs, locGMM, maxDist)

# print candidate point locations
for smallObj, points in candPoints.iteritems():
    print 'Querying for object:', smallObj.type
    for candPoint in points:
        print 'Location for candidate point:', candPoint.pos
    print ''