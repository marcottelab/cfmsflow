PCM_DIR=/project/cmcwhite/github/protein_complex_maps
EXP_PREFIX=wheat
GOLD_COMPLEXES=gold_standards/allComplexesCore_photo_euktovirNOG_expansion.txt
export PYTHONPATH=$PCM_DIR:$PYTHONPATH
shopt -s nullglob # Makes it so can check for output files

echo "run from protein_complexes_template base directory"

echo "format input elutions"
#bash records/record_format_elutions.sh

#####################
echo "create correlation commands, default 5 replications with poisson noise, use up to 100 for final calculations"
bash records/record_corr_commands_gen.sh $PCM_DIR 5

echo "run correlation commands"
cat records/record_corr_COMMANDS.sh | parallel -j30

(find "elutions/processed_elutions" -name "*.feat" | head -1)
echo "BLASDF"

if [ -f "$(find "elutions/processed_elutions" -name "*.feat" | head -1)" ] 
then    

    #echo elutions/processed_elutions/*.feat
    ls elutions/processed_elutions/*.feat
    echo "Features calculated (elutions/processed_elutions/*.feat)"

else
    echo "No output files from calculating features were found (elutions/processed_elutions/*.feat)"
    echo "Exiting"
    exit 1
fi
exit 1 
#####################

#####################
echo "make alphabetization commands"
bash records/record_alphabetize_commands_gen.sh $PCM_DIR

echo "run alphabetization commands"
cat records/record_alphabetize_COMMANDS.sh | parallel -j30


if [ -f "$(echo elutions/processed_elutions/*.feat.ordered | head -1)" ] 
then    
    ls elutions/processed_elutions/*.feat.ordered
    echo "Features ordered (elutions/processed_elutions/*.feat.ordered)"
else
    echo "No output files from alphabetizing feature IDs were found (elutions/processed_elutions/*.feat.ordered)"
    echo "Exiting"
    exit 1
fi

####################

echo "make rescale commands for distance features"
bash records/record_rescale_commands_gen.sh $PCM_DIR

echo "run rescale commands for distance features"
cat records/record_rescale_COMMANDS.sh | parallel -j30


if [ -f "$(echo elutions/processed_elutions/*.feat.rescale.ordered)" ] 
then   
    ls elutions/processed_elutions/*.feat.rescale.ordered 
    echo "Euclidean and Bray-Curtis features rescaled (elutions/processed_elutions/*.feat.rescale.ordered)"
else
    echo "No output files from rescaling distance features were found (elutions/processed_elutions/*.feat.rescale.ordered)"
    echo "Exiting"
    exit 1
fi


####################


echo "get feature names"
bash records/record_get_feature_names.sh


echo "build feature matrix"
bash records/record_build_feature_matrix.sh $PCM_DIR feature_matrix/features.txt 


exit 1
echo "format gold standards"
bash records/record_gold_standards.sh $PCM_DIR $EXP_PREFIX $GOLD_COMPLEXES

echo "feature matrix procession"
bash records/record_feature_matrix_processing.sh  

echo "feature selection"
bash records/record_feature_selection.sh  


echo "training"
bash records/record_training.sh 
