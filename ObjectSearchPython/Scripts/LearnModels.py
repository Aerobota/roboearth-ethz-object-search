#!/usr/bin/env python
'''
Created on Aug 15, 2013

Learns the GMM Models on ALL of the images. 
DOES NOT divide them into Test/Training to evaluate.

@author: okankoc
@contact: Stefan Koenig, Mohanarajah Gajamohan
'''

#importing the necessary modules for learning
from DataHandler import DataStructure
from Learner import EvidenceGenerator, Learner

## INITIALIZING

#set paths
#Path to the folder of the converted dataset
sourceFolder = "/home/okan/roboearth-ethz-object-search/"
datasetPath = sourceFolder + "Dataset/Images/"

#initialize classes
dataTrain = DataStructure.NYUDataStructure(datasetPath, "train")
dataTest = DataStructure.NYUDataStructure(datasetPath, "test")
locCylinder = EvidenceGenerator.CylindricalEvidenceGenerator(0,0)
locGMM = Learner.ContinuousGMMLearner(locCylinder)

## LOAD DATA

print "Loading data..."
dataTrain.loadDataMAT()
dataTest.loadDataMAT()

## LEARN PROBABILITIES
locGMM.learnBatchFull(dataTrain, dataTest, 'GMMFull')
