# Brain activity classification using task-based functional magnetic resonance imaging and different machine learning models (Bachelor honour thesis)
this repository contains code and preprocessed data for the project
***
## preprocess
all preprocess steps with MRI images are done with prepro.sh and loaddata.ipynb will transform the timeseris into data instances
the script uses  FMRIB Software Library(fsl): https://fsl.fmrib.ox.ac.uk/fsl/fslwiki
***
## classification
workspace.ipynb will load the preprocessed data and train the different models from scikit-learn https://scikit-learn.org/stable
***
### file structure

the parcellation used can be found in <a href="data/parcellation/shen">shen</a>

<a href="code/prepro.sh">prepro.sh</a> is the script for preprocessing 

<a href="code/atlas.sh">atlas</a> would create <a href="code/tempdata/">atlas information</a>

<a href="code/atlas.xlsx">atlas.xlsx</a> is merged from three different atlas maps

<a href="code/regions.py">regions.py</a> will create a brain MRI image with select areas highlighted

<a href="code/workspace.ipynb">workspace.ipynb</a> is the main code where every step is done


all preprocessed data that can be directly input to the models are stored <a href="code/tempdata/dis">here</a>

<a href="code/tempdata/important_regions_bi">important_regions_bi</a> contains the region numbers for the important regions

<a href="code/tempdata/sin/">here</a> contains the information about the important regions that are more related to each of the tasks