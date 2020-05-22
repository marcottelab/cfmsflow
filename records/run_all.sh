PCM_DIR=/project/cmcwhite/github/protein_complex_maps
EXP_PREFIX=wheat
GOLD_COMPLEXES=gold_standards/allComplexesCore_photo_euktovirNOG_expansion.txt
export PYTHONPATH=$PCM_DIR:$PYTHONPATH





echo "format input elutions"
#bash records/record_format_elutions.sh

# TODO: Add script to perform formatting check


if [ -f "$(find "elutions/processed_elutions" -name "*.wide" | head -1)" ] 
then    

    #echo elutions/processed_elutions/*.feat
    #ls elutions/processed_elutions/*.wide
    echo -e "\e[35mElutions formatted (elutions/processed_elutions/*.wide)\e[39m"

else
    echo -e "\e[91mNo output files from formatting elutions were found (elutions/processed_elutions/*.wide)\e[39m"
    echo -e "\e[91mExiting\e[39m"
    exit 1
fi
#

#####################
echo "create correlation commands, default 5 replications with poisson noise, use up to 100 for final calculations"
bash records/record_corr_commands_gen.sh $PCM_DIR 5

echo "run correlation commands"
cat records/record_corr_COMMANDS.sh | parallel -j30 &> logs/corr_commands.log


if [ -f "$(find "elutions/processed_elutions" -name "*.feat" | head -1)" ] 
then    

    #echo elutions/processed_elutions/*.feat
    #ls elutions/processed_elutions/*.feat
    echo -e "\e[35mFeatures calculated (elutions/processed_elutions/*.feat)\e[39m"

else
    echo -e "\e[91mNo output files from calculating features were found (elutions/processed_elutions/*.feat)\e[39m"
    echo -e "\e[91mExiting\e[39m"
    exit 1
fi
#####################

#####################
echo "make alphabetization commands"
bash records/record_alphabetize_commands_gen.sh $PCM_DIR

echo "run alphabetization commands"
cat records/record_alphabetize_COMMANDS.sh | parallel -j30 &> logs/alphabetize_commands.log 

if [ -f "$(find "elutions/processed_elutions" -name "*.feat.ordered" | head -1)" ] 
then    
    #ls elutions/processed_elutions/*.feat.ordered
    echo -e "\e[35mFeature IDs alphabetized (elutions/processed_elutions/*.feat.ordered\e[39m)"
else
    echo -e "\e[91mNo output files from alphabetizing feature IDs were found (elutions/processed_elutions/*.feat.ordered)\e[39m"
    echo -e "\e[91mExiting\e[39m"
    exit 1
fi
exit 1
####################

echo "make rescale commands for distance features"
bash records/record_rescale_commands_gen.sh $PCM_DIR

echo "run rescale commands for distance features"
cat records/record_rescale_COMMANDS.sh | parallel -j30  &> logs/rescale_commands.log 

if [ -f "$(find "elutions/processed_elutions" -name "*.feat.rescale.ordered" | head -1)" ] 
then   
    ls elutions/processed_elutions/*.feat.rescale.ordered 
    echo -e "\e[35mEuclidean and Bray-Curtis features rescaled (elutions/processed_elutions/*.feat.rescale.ordered\e[39m)"
else
    echo -e "\e[91mNo output files from rescaling distance features were found (elutions/processed_elutions/*.feat.rescale.ordered\e[39m)"
    echo -e "\e[91mExiting\e[39m"
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
