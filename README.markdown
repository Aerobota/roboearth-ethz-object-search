#Database Tools

##Setup
The [AnnotationTool](http://www.ipb.uni-bonn.de/html_pages_software/annotation-tool/downloads/08-11-21-annotation-tool-v-2-40.zip) is needed to run these tools. Unzip it into the folder "AnnotationTool" which needs to be on the sam directory as this README. For the AnnotationTool to work one must download the [LabelMeToolbox](http://labelme.csail.mit.edu/LabelMeToolbox/LabelMeToolbox.zip). The contents of the folder must be copied into "AnnotationTool/LabelMeToolbox".

##Usage
###Annotation

	annotate(PathToDataset)

This command starts the AnnotationTool, taking care of setting all the correct variables. For usage of the AnnotationTool see [here](http://www.ipb.uni-bonn.de/html_pages_software/annotation-tool/index.html).

###ImageLoader
This is an interface that takes care of collecting all the parts necessary to load the complete dataset instances. Contrary to the name not only the RGB-image is loaded but a structure containing RGB-image, depth-image, calibration matrix and the annotated objects. In the following text image will be used as a synonym for this structure.

####Constructor

	il=ImageLoader(PathToDataset)

Takes the relative or absolute path to the dataset and scans for all available data. This means that if the data changes the image loader has to be reinstantiated. The images are not kept in memory which allows for much larger datasets to be used.

####Image Loading

	image=il.getImage
	image=il.getImage(index)

Both commands load the specified image into memory and return it. The difference is that the second command is random-access, while the first command works similar to an iterator, always returning the next image. If the iterator has reached the end of the list it will return 0, it has to be reset with the following command:

	il.resetIterator

The getImage command not only loads the image into memory but also builds the combined structure from the individual file and saves it as a single .mat file for further use.

####Generate Collection

	il.generateCollection

This function builds all .mat files from the dataset. This is the same as calling getImage until it  returns 0. The only difference is that this function uses multi-threading if activated using [matlabpool](http://www.mathworks.ch/help/toolbox/distcomp/matlabpool.html).

##Dataset Structure
###Combined
The ImageLoader object saves all individual files into one single .mat for each image structure. This means that after the first time loading images is much faster. All .mat files are stored in the "combined" folder, if the dataset has changed, it is good practice to delete this folder to guarantee that all files are correctly reloaded.

###Single Files
The original files have to be placed in the correct folder and have to be correctly named. The naming convention is a tag, a unique identifier and the correct extension. In the examples the unique identifier is denoted by \*\*\*.

* Image files: image/img\_\*\*\*.jpg
* Depth files: depth/depth\_\*\*\*.txt
* Calibration files: calibration/calib\_\*\*\*.txt
* Annotation files: annotation/anno\_\*\*\*.xml __OR__ annotation/image/img\_\*\*\*.xml

The reason for the two locations of the annotation files is that the AnnotationTool automatically generates it's output in the second location, which is inconsistent with the rest of the files. The ImageLoader object will automagically clean it and put everything into the first location.
