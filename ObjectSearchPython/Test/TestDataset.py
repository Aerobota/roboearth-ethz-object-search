'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig, Mohanarajah Gajamohan
'''

#importing the necessary modules for learning
from Evaluator import Evaluator, Methods
from Learner import EvidenceGenerator, Learner
from DataHandler import DataStructure


## SET PARAMETERS

#maximum distances d_max
#inside which the location predictor gets a positive score
maxDistances = (0.25,0.5,1,1.5)

#set evaluation methods
evalMethod = (Methods.FROCLocationEvaluator(), Methods.FirstNLocationEvaluator())

## INITIALIZING

#set paths
#Path to the folder of the converted dataset
sourceFolder = "/home/okan/roboearth-ethz-object-search/"
datasetPath = sourceFolder + "Dataset/Images/"

#initialize classes
dataTrain = DataStructure.NYUDataStructure(datasetPath, "train")
dataTest = DataStructure.NYUDataStructure(datasetPath, "test")
locCylinder = EvidenceGenerator.CylindricalEvidenceGenerator()
locGMM = Learner.ContinuousGMMLearner(locCylinder)
evalBase = Evaluator.LocationEvaluator(maxDistances,evalMethod)

## LOAD DATA

print "Loading data..."
dataTrain.loadDataMAT()
dataTest.loadDataMAT()

## LEARN PROBABILITIES
locGMM.learn(dataTrain)

## EVALUATE ON ALL TEST IMAGES
imageNum = 20
#evalBase.displayResultsForImage(dataTest,imageNum,locGMM)

## EVALUATE ON ONE IMAGE
evalBase.evaluateOneImage(dataTest,imageNum,locGMM,maxDistances[2],evalMethod[1])