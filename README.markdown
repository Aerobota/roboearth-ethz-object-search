#Object Search

##Getting Started
###Obtaining Dataset
The dataset used in the thesis can be found [here (~3GB)][datasetLink].
This dataset needs to be converted to a more suitable format.
The following steps need to be undertaken to do this.

###Setting the Paths
It is necessary to modify the file `+Scripts/setPaths.m` for the program to find the dataset.
The variable `sourceFolder` needs to point to the folder where the downloaded file resides.
The variable `datasetPath` needs to point to the folder where the converted files will be saved in.

###Converting the Dataset
When the paths are set correctly run following script in Matlab:

	Scripts.extractDataset

This script takes some time to complete (~15 minutes). The process is parallelised and can be speeded up by using the command `matlabpool open` before running the script.

##Computing
###Occurrence Data
To obtain the evaluation plots for the occurrence the following two steps are necessary:

1. Learning and evaluating the data:

		Scripts.computeOccurrenceData

2. Plotting the result:

		Scripts.plotOccurrenceComparison2Baseline
		Scripts.plotOccurrenceStates
		Scripts.plotOccurrenceValueMatrix

The first step generates the file `tmpOccurrenceData.mat` where all computed data is stored. This file can be loaded instead of recomputing the data.

###Location Data
Similar as for the occurrence data there are two steps again. It has to be noted that the first step takes a very long time (>3 hours) to complete. The computation speed profits from multiple matlab workers obtained with `matlabpool open`, the computation speed scales almost linearly with the number of workers used.

1. Learning and evaluating the data:

		Scripts.computeLocationData

2. Plotting the results:

		Scripts.plotLocationComparison
		Scripts.plotLocationProbabilityContours

##Modifications
###Adapting other Dataset
Necessary data is:

* Depth images

* Calibration matrices

* Object bounding boxes with class annotation

To use another dataset with the code it is necessary to create a new `DataHandler` that inherits from `DataHandlers.DataStructure`.
Further the scripts `Scripts.computeOccurrenceData` and `Scripts.computeLocationData` need to be changed to use the new `DataHandler` instead of the standard `DataHandlers.NYUDataStructure`. Another possibility is to write a conversion script that uses `DataHandlers.NYUDataStructure.addImage` to add the new images to the `DataHandler`.

###Changing Output
All files in the `+Scripts` folder have a number of parameters in the first cell which can be used to produce different plots.


[datasetLink]: http://horatio.cs.nyu.edu/mit/silberman/nyu_depth_v2/nyu_depth_v2_labeled.mat


