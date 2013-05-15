'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig, Mohanarajah Gajamohan
'''

#importing the necessary modules for learning
from Evaluator import *
from Learner import *
from DataHandler import *


## SET PARAMETERS

#maximum distances d_max
#inside which the location predictor gets a positive score
maxDistances = (0.25,0.5,1,1.5)

#set evaluation methods
evalMethod = list()
evalMethod[1] = Methods.FROCLocationEvaluator()
evalMethod[2] = Methods.FirstNLocationEvaluator()

## INITIALIZING

#set paths
#Path to the folder of the converted dataset
sourceFolder = "../Dataset/"
datasetPath = sourceFolder + "Images/"

#initialize classes
dataTrain = DataStructure.NYUDataStructure(datasetPath, "train")
dataTest = DataStructure.NYUDataStructure(datasetPath, "test")
locCylinder = EvidenceGenerator.CylindricalEvidenceGenerator()
locGMM = Learner.ContinuousGMMLearner(locCylinder)
evalBase = Evaluator.LocationEvaluator()

## LOAD DATA

print "Loading data..."
dataTrain.loadDataMAT()
dataTest.loadDataMAT()

## LEARN PROBABILITIES

print "Learning probabilities for Gaussian Mixture Model (GMM)"
locGMM.learn(dataTrain)