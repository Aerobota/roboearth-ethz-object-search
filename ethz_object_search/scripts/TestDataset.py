#!/usr/bin/env python
'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig, Mohanarajah Gajamohan
'''

import os.path

import roslib; roslib.load_manifest('ethz_object_search')
from rospkg import RosPack

#importing the necessary modules for learning
from ethz_object_search.data_structure import NYUDataStructure
from ethz_object_search.learner import ContinuousGMMLearner
from ethz_object_search.evidence_generator import CylindricalEvidenceGenerator
from ethz_object_search.evaluator import LocationEvaluator
from ethz_object_search.methods import FROCLocationEvaluator, FirstNLocationEvaluator


## SET PARAMETERS

PKG_PATH = RosPack().get_path('ethz_object_search')
MODEL_PATH = os.path.join(PKG_PATH, 'data/GMMTraining')

#maximum distances d_max
#inside which the location predictor gets a positive score
maxDistances = (0.25, 0.5, 1, 1.5)

#set evaluation methods
evalMethod = (FROCLocationEvaluator(), FirstNLocationEvaluator())

#set paths
#Path to the folder of the converted dataset
datasetPath = os.path.join(PKG_PATH, 'Dataset/Images')


def main():
    ## INITIALIZING

    #initialize classes
    dataTrain = NYUDataStructure(datasetPath, "train")
    dataTest = NYUDataStructure(datasetPath, "test")
    locCylinder = CylindricalEvidenceGenerator()
    locGMM = ContinuousGMMLearner(locCylinder)
    evalBase = LocationEvaluator(maxDistances, evalMethod)

    ## LOAD DATA

    print "Loading data..."
    dataTrain.loadDataMAT()
    dataTest.loadDataMAT()

    ## LEARN PROBABILITIES
    locGMM.learn(dataTrain, MODEL_PATH)

    ## EVALUATE ON ALL TEST IMAGES
    imageNum = 20
    #evalBase.displayResultsForImage(dataTest,imageNum,locGMM)

    ## EVALUATE ON ONE IMAGE
    evalBase.evaluateOneImage(dataTest, imageNum, locGMM, maxDistances[2], evalMethod[1])


if __name__ == '__main__':
    main()
