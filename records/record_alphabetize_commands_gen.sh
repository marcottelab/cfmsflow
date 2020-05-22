PCM_DIR=$1

for feat in elutions/processed_elutions/*feat
    do
       echo "python $PCM_DIR/protein_complex_maps/features/alphabetize_pairs.py --feature_pairs $feat --outfile ${feat%.txt}.ordered --sep ','"
    done > records/record_alphabetize_COMMANDS.sh  

# cat record_alphabetize_COMMANDS.sh > parallel -j 30

