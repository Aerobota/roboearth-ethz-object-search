#!/usr/bin/env python
'''
Created on Aug 14, 2013

This scenario investigates the use of one-sample inference.
@author: okankoc

@author: okan

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


MODEL_PATH = os.path.join(RosPack().get_path('ethz_object_search'), 'data/GMMFull')


def init(loc_large, loc_small):
    ## Create a semantic map
    print 'Creating a semantic map...'
    semMap = SemMap()
    semMap.header.frame_id = "http://www.example.com/foo.owl#"
    semMap.header.stamp = 0

    #create object - cabinet
    obj = SemMapObject()
    obj.id = 1
    obj.partOf = 0
    obj.type = 'table'
    obj.loc = loc_large
    obj.depth = 1
    obj.width = 1
    obj.height = 1

    #obj.pose = [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
    semMap.objects.append(obj)

    #small object to learn model of
    smallObjs = []
    smallObjs.append(SmallObject('serial box', loc_small))

    return semMap, smallObjs


def main():
    maxDist = 1.0
    # the amount by which the mesh is stretched
    stretch = 0.5
    # fineness of the grid, in terms of meters
    gridResolution = 0.05

    semMap1, smallObjs = init([0.0, 0.0, 0.0], [0.5, 0.4, 0.3])

    # load the pickled GMM Models
    locCylinder = CylindricalEvidenceGenerator(stretch, gridResolution)
    locGMM = ContinuousGMMLearner(locCylinder)
    locGMM.load(MODEL_PATH)
    locGMM.learnFromOneSample(semMap1, smallObjs, MODEL_PATH)

    semMap2, smallObjs = init([0.6, 0.6, 0.6], None)

    evalBase = LocationEvaluator(maxDist, [])
    candPoints = evalBase.infer(semMap2, smallObjs, locGMM, maxDist)

    # print candidate point locations
    for smallObj, points in candPoints.iteritems():
        print 'Querying for object:', smallObj.type
        for candPoint in points:
            print 'Location for candidate point:', candPoint.pos
        print ''


if __name__ == '__main__':
    main()
