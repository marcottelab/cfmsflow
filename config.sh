######## General params

PCM_DIR=/project/cmcwhite/github/for_pullreqs/protein_complex_maps

GEN_COMMANDS_ONLY=F

####### Choose steps to run, set to F to skip

RUN_FEATURES=T
RUN_GET_FEAT_FILE=T
RUN_BUILD_FEATMAT=T
RUN_GOLDSTANDARD=T
RUN_LABEL_FEATMAT=T
RUN_SCAN=T
RUN_TRAIN=T
RUN_SCORE=T
RUN_CLUSTER=T

######## Params for calculating features (cfmsinfer-features, cfmsinfer-rescale, cfmsinfer-alphabetize)
EXPLIST=explist.txt
ADD_POISSON_NOISE=T
SKIP_CORR=F
SKIP_ALPHABETIZE=F
POISSON_REPS=5


######## Params for building feature matrix (cfmsinfer-getfeatnames, cfmsinfer-build)
EXP_PREFIX=testrun
FEAT_FILE=feature_matrix/features.txt
STORE_INTERVAL=10

####### Params for creating gold standard interactions (cfmsinfer-gold)
GOLD_COMPLEXES=accessory_files/allComplexesCore_photo_euktovirNOG_expansion.txt
MERGE_THRESHOLD=0.6
COMPLEX_SIZE_THRESHOLD=30
LIMIT_NEGATIVES=20000
MAKE_NEGATIVES_FROM_OBSERVED=T
MAKE_NEGATIVES_FROM_INTERCOMPLEX=F

####### Params for training (cfmsinfer-label, cfmsinfer-scan, cfmsinfer-train, cfmsinfer-score)
TPOT_DIR=/project/cmcwhite/github/run_TPOT/

# For cfmsinfer-scan only
CLASSIFIERS_TO_SCAN=accessory_files/all_classifiers.txt
GENERATIONS=10
POPULATION=20

####### Params for interaction clustering (cfmsinfer-cluster)
CUTOFF=1000
THRESHOLD=
WALKTRAP_STEPS=4
ANNOTATION_FILE=''
ELUTION_FILE=elutions/processed_elutions/ex_all_expconcat_elut_expnormspeccounts.wide

