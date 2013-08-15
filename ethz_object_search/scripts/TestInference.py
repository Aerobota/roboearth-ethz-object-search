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

import os.path

import roslib; roslib.load_manifest('ethz_object_search')
from rospkg import RosPack

from mod_semantic_map.msg import SemMap, SemMapObject

from ethz_object_search.data_structure import SmallObject
from ethz_object_search.learner import ContinuousGMMLearner
from ethz_object_search.evidence_generator import CylindricalEvidenceGenerator
from ethz_object_search.evaluator import LocationEvaluator

################################################################################
### HACK TO ADD FIELD 'loc' TEMPORARY
def get_loc(self):
    if len(self.pose) != 12:
        raise ValueError('No location specified.')

    return [self.pose[3], self.pose[7], self.pose[11]]

def set_loc(self, loc):
    assert len(loc) == 3, 'Location has to be a 3D vector.'
    if len(self.pose) != 12:
        self.pose = [0] * 12

    self.pose[3], self.pose[7], self.pose[11] = loc

SemMapObject.loc = property(get_loc, set_loc)
### HACK END
################################################################################


MODEL_PATH = os.path.join(RosPack().get_path('ethz_object_search'), 'data/GMMmodels.bin')


def init():
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

    #obj1.pose = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
    #obj2.pose = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
    semMap.objects.append(obj1)
    semMap.objects.append(obj2)

    #small objects to query for
    smallObjs = []
    smallObjs.append(SmallObject('bottle'))

    return semMap, smallObjs


def main():
    ## Query for candidate points
    maxDist = 1.0
    # the amount by which the mesh is stretched
    stretch = 0.5
    # fineness of the grid, in terms of meters
    gridResolution = 0.05

    semMap, smallObjs = init()

    # TODO: make sure the whole dataset is learned

    # load the pickled GMM Models
    locCylinder = CylindricalEvidenceGenerator(stretch, gridResolution)
    locGMM = ContinuousGMMLearner(MODEL_PATH, locCylinder)
    locGMM.load()

    evalBase = LocationEvaluator(maxDist, [])
    candPoints = evalBase.infer(semMap, smallObjs, locGMM, maxDist)

    # print candidate point locations
    for candPoint in candPoints:
        print 'Location for candidate point:', candPoint.pos


if __name__ == '__main__':
    main()
