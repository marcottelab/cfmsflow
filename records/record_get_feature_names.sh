ls elutions/processed_elutions/*pearsonR*ordered > feature_matrix/features.txt
ls elutions/processed_elutions/*spearmanR*ordered >> feature_matrix/features.txt
#ls elutions/processed_elutions/*xcorr*ordered >> feature_matrix/features.txt
ls elutions/processed_elutions/*braycurtis*rescale.ordered >> feature_matrix/features.txt
ls elutions/processed_elutions/*euclidean*rescale.ordered >> feature_matrix/features.txt
