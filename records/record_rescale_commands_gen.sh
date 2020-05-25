#! /bin/bash
CONFIG=$1
source $CONFIG

while read exp
do
    for f in elutions/processed_elutions/*euclidean*feat.ordered; do 
         echo "python $PCM_DIR/protein_complex_maps/features/normalize_features.py --input_feature_matrix $f --output_filename ${f%.ordered}.rescale.ordered --features euclidean --min 0 --sep , --inverse" 
         done > records/record_rescale_COMMANDS.sh
    
    for f in elutions/processed_elutions/*braycurtis*feat.ordered; do 
         echo "python $PCM_DIR/protein_complex_maps/features/normalize_features.py --input_feature_matrix $f --output_filename ${f%.ordered}.rescale.ordered --features braycurtis --min 0 --sep , --inverse"; done >> records/record_rescale_COMMANDS.sh

done < $EXPLIST 
    
# cat records/record_rescale_COMMANDS.sh | parallel -j30
