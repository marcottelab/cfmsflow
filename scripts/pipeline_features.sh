set -e
CONFIG=$1
echo $CONFIG 

if [ -f $CONFIG ]; then
   echo "Please provide a config file as the first command line argument to this script"
   echo "Ex. bash scripts/pipeline_training.sh config.sh"
   exit 1
fi

source $CONFIG
cat $CONFIG

export PYTHONPATH=$PCM_DIR


if [ "$RUN_FEATURES" == "T" ]; then

    if [ "$RUN_CORR" == "T" ]; then
        ./scripts/cfmsinfer-corr $CONFIG
    fi

    if [ "$RUN_ALPHABETIZE" == "T" ]; then
        ./scripts/cfmsinfer-alphabetize $CONFIG
    fi

    if [ "$RUN_RESCALE" == "T" ]; then
        ./scripts/cfmsinfer-rescale $CONFIG
    fi
fi

