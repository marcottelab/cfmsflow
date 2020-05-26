######## General params

PCM_DIR=/project/cmcwhite/github/protein_complex_maps

####### Choose steps to run, set to F to skip

RUN_CORR=T
RUN_ALPHABETIZE=T
RUN_RESCALE=T
RUN_BUILD_FEATMAT=T
RUN_FORMAT_GOLDSTANDARD=T
RUN_LABEL_FEATMAT=T
RUN_TRAIN=T

######## Params for calculating features
EXPLIST=explist.txt

# If F, will skip RUN_CORR, RUN_ALPHABETIZE, and RUN_RESCALE
RUN_FEATURES=T

ADD_POISSON_NOISE=T

# Times to rerun correlations with poisson noise. 5 reps to test, up to 100 reps used in previous complex maps
POISSON_REPS=5


######## Params for building feature matrix
EXP_PREFIX=text

####### Params for creating gold standard interactions
GOLD_COMPLEXES=gold_standards/allComplexesCore_photo_euktovirNOG_expansion.txt
#RUN_FORMAT=F


