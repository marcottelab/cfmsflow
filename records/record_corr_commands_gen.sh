#! /bin/bash
CONFIG=$1
source $CONFIG

while read exp
        do for corr in pearsonR spearmanR euclidean braycurtis #xcorr
           do 

              rm logs/log_corr_${exp##*/}_${corr} 
              rm logs/error_corr_${exp##*/}_${corr}


               if [ $ADD_POISSON_NOISE == "T" ]; then

                  if [[ -z $POISSON_REPS ]]; then
                      echo 'POISSON_REPS undefined in config file. ex. POISSON_REPS=5'
                      exit 1
                  fi


                   echo "python $PCM_DIR/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv -f $corr -r poisson_noise -i $POISSON_REPS $exp > logs/log_corr_${exp##*/}_${corr} 2> logs/error_corr_${exp##*/}_${corr}"
               else
                   echo "python $PCM_DIR/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv -f $corr $exp > logs/log_corr_${exp##*/}_${corr} 2> logs/error_corr_${exp##*/}_${corr}"
 
               fi
           

           done
        done < $EXPLIST >  records/record_corr_COMMANDS.sh



