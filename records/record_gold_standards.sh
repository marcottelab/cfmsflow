PCM_DIR=$1
EXP_PREFIX=$2
COMPLEXES=$3
#Ex gold_standards/allComplexesCore_photo_euktovirNOG_expansion.txt

# Input format is one complex per line, each protein separated by a space
# A B C
# D E

# Remove very large complexes
python $PCM_DIR/protein_complex_maps/corum/complex_merge.py --cluster_filename $COMPLEXES --output_filename gold_standards/Positives_merged06_size30_rmLrg_rmSub.txt --merge_threshold 0.6 --complex_size_threshold 30 --remove_largest --remove_large_subcomplexes

# Split complexes to training and test complexes
python $PCM_DIR/protein_complex_maps/preprocessing_util/complexes/split_complexes.py --input_complexes gold_standards/Positives_merged06_size30_rmLrg_rmSub.txt

# Alphabetize training and test interactions. 
for ppi in gold_standards/*ppis.txt
    do 
        python $PCM_DIR/protein_complex_maps/features/alphabetize_pairs.py --feature_pairs $ppi --outfile ${ppi%.txt}.ordered --sep '\t'
    done


# Get all ID pairs from the feature matrix (remove header with tail)
awk -F',' '{print $1}' feature_matrix/${EXP_PREFIX}_feature_matrix.csv |  tail -n +2 > gold_standards/labels

# Remove any interactions that are in the positive set
grep -vFf gold_standards/Positives_merged06_size30_rmLrg_rmSub.train_ppis.ordered gold_standards/labels | grep -vFf gold_standards/Positives_merged06_size30_rmLrg_rmSub.test_ppis.ordered > gold_standards/labels.filt

# Draw random negatives from all possible labels
sort -R gold_standards/labels.filt > gold_standards/labels.filt.randsort 

head -20000 gold_standards/labels.randsort.filt > gold_standards/labels.negtrain.20k 
tail -20000 gold_standards/labels.randsort.filt > gold_standards/labels.negtest.20k 

# Make annotation file of which interactions are training and which are test

#:Rscript scripts/make_test_train_annotation.R -ptst gold_standards/Positives_merged06_size30_rmLrg_rmSub.test_ppis.ordered -ptrn gold_standards/Positives_merged06_size30_rmLrg_rmSub.train_ppis.ordered -ntst gold_standards/labels.negtest.20k -ntrn gold_standards/labels.negtrain.20k -o gold_standards/Gold_standard_merged06_size30_rmLrg_rmSub.TestTrain.annot



