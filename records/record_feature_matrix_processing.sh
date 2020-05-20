
# FIX THIS 
# Problem where there's an extra line with the feature type header
#grep -v ",braycurtis," feature_matrix.csv > tmp
#mv tmp feature_matrix.csv

# Adding label of gold standard training complexes
python /project/cmcwhite/github/protein_complex_maps/protein_complex_maps/features/add_label.py --input_feature_matrix feature_matrix/example_feature_matrix.csv --input_positives gold_standards/allComplexesCore2019_merged06_size30_rmLrg_rmSub.train_ppis.ordered --input_negatives gold_standards/labels.negtrain.20k --sep , --ppi_sep '\t' --id_column ID --output_file feature_matrix/example_feature_matrix.labeled --fillna 0 --id_sep ' '
# Get training labeled interactions
grep -v ",0.0$" feature_matrix/example_feature_matrix.labeled > feature_matrix/example_feature_matrix.labeled1 

# Check why this was csv and not .txt list of features
#Feature selection
python /project/cmcwhite/github/protein_complex_maps/protein_complex_maps/features/feature_selections.py --feature_names feature_matrix/features.txt --plainfeatmat feature_matrix/example_feature_matrix.labeled1 --output_file feature_matrix/example_feature_matrix.labeled1.featselect


# Reduce feature matrix to just features from feature selection
python /project/cmcwhite/github/protein_complex_maps/protein_complex_maps/model_fitting/svm_utils/feature2featsel.py --input_feature_matrix example_feature_matrix.featmat.labeled --feature_file feature_selection/example_top100_features_ETC.txt --id_column ID --label_column label --output_filename feature_selection/example_feature_matrix.featmat.top100.labeled --sep ','

#featselect labeled -> one with removed_labels, one with select labeled1 

grep -v ",0.0$" example_feature_matrix.geatselect.labeled.tpot > feature_matrix.csv.featselect.labeled1.tpot

# Remove labels from the feature selected matrix for prediction. 
#cat example_feature_matrix.labeled.tpot | rev | cut -d, -f2- | rev >  example_feature_matrix.unlabeled.tpot




