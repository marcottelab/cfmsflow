#! /bin/bash
CONFIG=$1
source $CONFIG


while read exp
  do
    for feat in ${exp%.wide}*euclidean.feat.ordered
      do 

        rm -f logs/log_rescale_${feat##*/}
        rm -f logs/error_error_rescale_${exp##*/}

        echo "python $PCM_DIR/protein_complex_maps/features/normalize_features.py --input_feature_matrix $feat --output_filename ${f%.ordered}.rescale.ordered --features euclidean --min 0 --sep , --inverse  > logs/log_rescale_${feat##*/} 2> logs/error_rescale_${feat##*/}" 
      done   

    for feat in ${exp%.wide}*braycurtis.feat.ordered
      do  

        rm -f logs/log_rescale_${feat##*/}
        rm -f logs/error_error_rescale_${exp##*/}

        echo "python $PCM_DIR/protein_complex_maps/features/normalize_features.py --input_feature_matrix $f --output_filename ${f%.ordered}.rescale.ordered --features braycurtis --min 0 --sep , --inverse > logs/log_rescale_${feat##*/} 2> logs/error_rescale_${feat##*/}"
      done   
  done < $EXPLIST > records/record_rescale_COMMANDS.sh 
  
# cat records/record_rescale_COMMANDS.sh | parallel -j30
