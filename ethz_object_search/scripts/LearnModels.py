#!/usr/bin/env python
'''
Created on Aug 15, 2013

Learns the GMM Models on ALL of the images.
DOES NOT divide them into Test/Training to evaluate.

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


## SET PARAMETERS

PKG_PATH = RosPack().get_path('ethz_object_search')
MODEL_PATH = os.path.join(PKG_PATH, 'data/GMMTraining')

#set paths
#Path to the folder of the converted dataset
datasetPath = os.path.join(PKG_PATH, 'Dataset/Images')


def main():
    ## INITIALIZING

    #initialize classes
    dataTrain = NYUDataStructure(datasetPath, "train")
    dataTest = NYUDataStructure(datasetPath, "test")
    locCylinder = CylindricalEvidenceGenerator(0, 0)
    locGMM = ContinuousGMMLearner(locCylinder)

    ## LOAD DATA

    print "Loading data..."
    dataTrain.loadDataMAT()
    dataTest.loadDataMAT()

    ## LEARN PROBABILITIES
    locGMM.learnBatchFull(dataTrain, dataTest, MODEL_PATH)


if __name__ == '__main__':
    main()
