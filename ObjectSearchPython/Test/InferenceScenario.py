'''
Created on July 29, 2013

This scenario investigates the use of inference in learned models.
@author: okankoc

TODO:
1. Build a dictionary relating object classes to definitions in knowrob.url
2. Receive a semantic map and parse it.
3. Infer the location of searched object (candidatePoints)
4. Send the most likely location(s) back.

'''

from SemanticMap.SemMap import SemMap, SemMapObject
from Learner import EvidenceGenerator, Learner
from Evaluator import Evaluator
from DataHandler import DataStructure
 
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
obj1.loc = [0.0,0.0,0.0]
obj1.depth = 1
obj1.width = 1
obj1.height = 1

obj1.pose = [1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,1.0]
semMap.objects.append(obj1)

#small objects to query for
smallObj = ['bottle']

#point cloud locations
#make do with any image point cloud for now 
sourceFolder = "/home/okan/roboearth-ethz-object-search/"
datasetPath = sourceFolder + "Dataset/Images/"
dataTest = DataStructure.NYUDataStructure(datasetPath, "test")
dataTest.loadDataMAT()
image = dataTest.data[0]
pcloud = dataTest.get3DPositionForImage(image)

# load the pickled GMM Models
locCylinder = EvidenceGenerator.CylindricalEvidenceGenerator()
locGMM = Learner.ContinuousGMMLearner(locCylinder)
locGMM.load()

## Query for candidate points        
maxDist = 1.5
evalBase = Evaluator.LocationEvaluator(maxDist,[])
candPoints = evalBase.infer(semMap,pcloud,smallObj,locGMM,maxDist)
print candPoints