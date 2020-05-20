# FIX THIS AND build_featmat script
# Re: Interval outfput filenaming
# And give store interval a default or a check

FEATURES=feature_matrix/features.txt # One filename per line of the features you want to use
EXP_ID=wheat
FEATURE_STR=$(cat $FEATURES | tr '\n' ' ')
#EXISTING_MATRIX=
OUTPUT_FILE=feature_matrix/${EXP_ID}_feature_matrix.csv

echo ID: $EXP_ID
echo Feature file : $FEATURES
echo Features: $FEATURE_STR
echo Existing matrix: $EXISTING_MATRIX
echo Output_file: $OUTPUT_FILE


#/project/cmcwhite/github/for_pullreqs
python3 /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/features/build_feature_matrix.py --input_pairs_files $FEATURE_STR --store_interval 1 --output_file $OUTPUT_FILE --sep ','


# If fails midway, can restart by setting EXISTING MATRIX, and using the below command
#python /project/cmcwhite/github/protein_complex_maps/protein_complex_maps/features/build_feature_matrix.py --prev_feature_matrix $EXISTING_MATRIX --input_pairs_files $FEATURE_STR --output_file $OUTPUT_FILE --store_interval 20 --sep ','



