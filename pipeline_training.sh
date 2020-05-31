#! /bin/bash
set -e
CONFIG=$1 

if [ ! -f $CONFIG ]; then
   echo "Please provide a config file"
   exit 1
fi

source $CONFIG
cat $CONFIG
export PYTHONPATH=$PCM_DIR


if [ "$RUN_GET_FEAT_FILE" == "T" ]; then
    ./scripts/cfmsinfer-getfeatnames $CONFIG
fi

if [ "$RUN_BUILD_FEATMAT" == "T" ]; then
    ./scripts/cfmsinfer-build $CONFIG
fi

if [ "$RUN_GOLDSTANDARD" == "T" ]; then
    ./scripts/cfmsinfer-gold $CONFIG
fi

if [ "$RUN_LABEL_FEATMAT" == "T" ]; then
    ./scripts/cfmsinfer-label $CONFIG
fi

if [ "$RUN_SCAN" == "T" ]; then
    ./scripts/cfmsinfer-scan $CONFIG
fi

if [ "$RUN_TRAIN" == "T" ]; then
    ./scripts/cfmsinfer-train $CONFIG
fi

if [ "$RUN_SCORE" == "T" ]; then
    ./scripts/cfmsinfer-score $CONFIG
fi



