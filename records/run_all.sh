PCM_DIR=/project/cmcwhite/github/protein_complex_maps/protein_complex_maps
EXP_PREFIX=wheat

echo "run from protein_complexes_template base directory"

echo "format input elutions"
#bash records/record_format_elutions.sh

echo "create correlation commandsm, default 5 replications with poisson noise, use up to 100 for final calculations"
bash records/record_corr_commands_gen.sh 5 $PCM_DIR

echo "run correlation commands"
cat records/record_corr_COMMANDS.sh | parallel -j30


echo "make alphabetization commands"
bash records/record_alphabetize_commands_gen.sh $PCM_DIR

echo "run alphabetization commands"
cat records/record_alphabetize_COMMANDS.sh | parallel -j30

echo "make rescale commands for distance features"
bash records/record_rescale_commands_gen.sh $PCM_DIR

echo "run rescale commands for distance features"
cat records/record_rescale_COMMANDS.sh | parallel -j30

echo "get feature names"
bash records/record_get_feature_names.sh


echo "build feature matrix"
bash records/record_build_feature_matrix.sh $PCM_DIR feature_matrix/features.txt $EXP_PREFIX 5 

exit 1
echo "format gold standards"
bash records/record_gold_standards.sh $PCM_DIR

echo "feature matrix procession"
bash records/record_feature_matrix_processing.sh  

echo "feature selection"
bash records/record_feature_selection.sh  


echo "training"
bash records/record_training.sh 
