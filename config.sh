EXPLIST=explist.txt
PCM_DIR=/project/cmcwhite/github/protein_complex_maps
EXP_PREFIX=text
GOLD_COMPLEXES=gold_standards/allComplexesCore_photo_euktovirNOG_expansion.txt
#RUN_FORMAT=F

# If F, will skip RUN_CORR, RUN_ALPHABETIZE, and RUN_RESCALE
RUN_FEATURES=T

# Whether to run correlations on wide input matrices
RUN_CORR=T

# Only T for count data
ADD_POISSON_NOISE=T

# 5 reps to test, up to 100 reps used in previous complex maps
POISSON_REPS=5

RUN_ALPHABETIZE=T
RUN_RESCALE=F

RUN_BUILD_FEATMAT=T
RUN_FORMAT_GOLDSTANDARD=T
RUN_LABEL_FEATMAT=T
RUN_TRAIN=T
