PCM_DIR=$1
FEAT_FILE=$2

if [ -n "$3" ]; then
  EXP_PREFIX=$3
  OUTPUT_FILE=feature_matrix/${EXP_PREFIX}_feature_matrix.csv
else
  OUTPUT_FILE=feature_matrix/feature_matrix.csv
fi

# A intermediate file will be saved every x features
if [ -n "$4" ]; then
  STORE_INTERVAL=$4
else
  STORE_INTERVAL=50

fi

echo "protein_complex_maps directory: $PCM_DIR" 
echo "Feature file: $FEAT_FILE"
echo "Output file: $OUTPUT_FILE"
echo "Stores an intermediate file every $STORE_INTERVAL features" 

python $PCM_DIR/protein_complex_maps/features/build_feature_matrix.py --input_pairs_list $FEAT_FILE --store_interval $STORE_INTERVAL --output_file $OUTPUT_FILE --sep ','


# If fails midway, can restart by setting EXISTING MATRIX, and using the below command
#python $PCM_DIR/protein_complex_maps/features/build_feature_matrix.py --prev_feature_matrix $EXISTING_MATRIX --input_pairs_list $FEAT_LIST --output_file $OUTPUT_FILE --store_interval $STORE_INTERVAL --sep ','


