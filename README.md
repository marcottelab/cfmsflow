





### Update this
records: Records of commands run in course of analysis. Paths are local, but pattern can be used to compose commands in other systems

accessory_files: Contains external files used during data analysis

data_files: Contains files used in data analysis
 
scripts: Utility scripts for assembling data sets, and figures_manuscript_[date].Rmd used to create plots for paper figures

training: Location for training models, and output annotated co-fractionation mass spectrometry (CF-MS) scored edges
 
feature_selection: Location for running feature selection on training-set labeled feature matrix

gold_standard: Gold standard training and test interactions. Positive interactions were derived from CORUM protein complexes supplemented with known plant PPI, and negative interactions composed of random pairs present in full feature matrix


features: Location for calculated features from elution profiles. Not included in Zenodo due to size, but can be extracted from full feature_matrix

protein_identification: Location for creating protein and orthogroup elution profiles from process mass spec output files (Msblender output). See protein_identification directory for more details

