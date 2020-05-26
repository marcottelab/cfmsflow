#! /bin/bash
CONFIG=$1


# START WITH INPUT LIST OF FILES


if [ ! -f "$CONFIG" ]
  then
      
      CONFIG=records/config.sh
      if [ -f "$CONFIG" ]
      then
          source $CONFIG
      else
          echo -e  "\e[91mNo config script found\e[39m"
          echo -e  "\e[91mExiting\e[39m"
          exit 1
     fi
fi
echo -e "\e[32mUsing config script $CONFIG\e[39m"
cat $CONFIG
export PYTHONPATH=$PCM_DIR:$PYTHONPATH

if [[ -z $PCM_DIR ]]; then
  echo 'One or more variables are undefined in config script'
  echo 'Set Path to protein_complex_maps directory \$PCM_DIR, A prefix for this experiment \$EXP_PREFIX, and a file of gold standard complexes \$GOLD_COMPLEXES'
  exit 1
fi


if [ "$RUN_FORMAT" == "T" ]
then
    rm elutions/processed_elutions/*wide
    
    echo -e "\e[32mFormat input elutions (records/record_format_elutions.sh)\e39m"
    bash records/record_format_elutions.sh &> logs/format_elutions.log
    
    # TODO: Add script to perform formatting check
    
    echo -e "\e[34mLogged at logs/format_elutions.log\e[39m"
    if [ -f "$(find "elutions/processed_elutions" -name "*.wide" | head -1)" ] 
    then    

        echo -e "\e[35mElutions formatted (elutions/processed_elutions/*.wide)\e[39m"
    else
        echo -e "\e[91mNo output files from formatting elutions were found (elutions/processed_elutions/*.wide)\e[39m"
        echo -e "\e[91mExiting\e[39m"
    exit 1
    fi
else
    echo -e "\e[91mSkipping formatting elution step (records/record_format_elution.sh)\e[39m"
fi
echo ""

#####################
if [ "$RUN_CORR" == "T" ]
then
    rm elutions/processed_elutions/*feat 2> /dev/null
    rm elutions/processed_elutions/*feat.ordered 2> /dev/null
    rm elutions/processed_elutions/*feat.rescale.ordered 2> /dev/null

    echo -e "\e[36mCreate correlation commands (records/record_corr_commands_gen.sh)\ndefault 5 replications with poisson noise, use up to 100 for final calculation\e[39m"
    bash records/record_corr_commands_gen.sh $PCM_DIR 5
    
    echo -e "\e[32mRun correlation commands (records/record_corr_COMMANDs.sh)"
    cat records/record_corr_COMMANDS.sh | parallel -j30 &> logs/corr_commands.log
    
    echo -e "\e[34mLogged at logs/corr_commands.log\e[39m"
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
else
    echo -e "\e[91mSkipping calculating features step (records/record_corr_COMMANDS.sh)\e[39m"
fi
echo ""
#####################

# INSTEAD of rm, do error handling better
# Record when error occurs in script
#####################

if [ "$RUN_ALPHABETIZE" == "T" ]
then
    rm elutions/processed_elutions/*feat.ordered 2> /dev/null
    rm elutions/processed_elutions/*feat.rescale.ordered 2> /dev/null
       
    echo -e "\e[36mMake alphabetization commands (records/record_alphabetize_commands_gen.sh"
    bash records/record_alphabetize_commands_gen.sh $PCM_DIR
    
    echo -e "\e[32mRun alphabetization commands (records/record_alphabetize_COMMANDS.sh"
    cat records/record_alphabetize_COMMANDS.sh | parallel -j30 &> logs/alphabetize_commands.log 
    echo -e "\e[34mLogged at logs/alphabetize_commands.log\e[39m"
    
    if [ -f "$(find "elutions/processed_elutions" -name "*.feat.ordered" | head -1)" ] 
    then    
        echo -e "\e[35mFeature IDs alphabetized (elutions/processed_elutions/*.feat.ordered\e[39m)"
    else
        echo -e "\e[91mNo output files from alphabetizing feature IDs were found (elutions/processed_elutions/*.feat.ordered)\e[39m"
        echo -e "\e[91mExiting\e[39m"
        exit 1
    fi
else
    echo -e "\e[91mSkipping alphabetize feature ID columns step (records/record_alphabetize_COMMANDS.sh)\e[39m"
fi

echo ""
####################

if [ "$RUN_RESCALE" == "T" ]
then
    rm elutions/processed_elutions/*feat.rescale.ordered 2> /dev/null
 
    echo -e "\e[36mMake rescale commands for distance feature\e[39m"
    bash records/record_rescale_commands_gen.sh $PCM_DIR
    
    echo -e "\e[32mRun rescale commands for distance feature\e[39m"
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
else
    echo -e "\e[91mSkipping rescale distance features step (records/record_rescale_COMMANDS.sh)\e[39m"
fi

exit 1
####################


echo -e "\e[32mget feature name\e[39m"
bash records/record_get_feature_names.sh


echo -e "\e[32mbuild feature matrix"
bash records/record_build_feature_matrix.sh $PCM_DIR feature_matrix/features.txt 


exit 1
echo -e "\e[32mformat gold standard\e[39m"
bash records/record_gold_standards.sh $PCM_DIR $EXP_PREFIX $GOLD_COMPLEXES

echo -e "\e[32mfeature matrix procession"
bash records/record_feature_matrix_processing.sh  

echo -e "\e[32mfeature selection"
bash records/record_feature_selection.sh  


echo -e "\e[36mtraining"
bash records/record_training.sh 
