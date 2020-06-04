#! /bin/bash
CONFIG=$1
source $CONFIG

while read exp
  do for corr in pearsonR spearmanR euclidean braycurtis #xcorr
   do 
     LOGNAME=${exp##*/}
     LOGNAME=${LOGNAME%.wide}_${corr}

     rm -f logs/log_corr_$LOGNAME
     rm -f errors/error_corr_$LOGNAME


     if [ $ADD_POISSON_NOISE == "T" ]
       then

         if [[ -z $POISSON_REPS ]]
           then
             echo 'POISSON_REPS undefined in config file. ex. POISSON_REPS=5'
             exit 1
         fi


         echo "python $PCM_DIR/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv -f $corr -r poisson_noise -i $POISSON_REPS $exp > logs/log_corr_${LOGNAME} 2> errors/error_corr_${LOGNAME}"
       else
         echo "python $PCM_DIR/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv -f $corr $exp > logs/log_corr_${LOGNAME} 2> errors/error_corr_${LOGNAME}"
 
       fi
   

    done
  done < $EXPLIST >  records/record_corr_COMMANDS.sh



