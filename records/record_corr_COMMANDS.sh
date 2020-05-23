python 5/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv -f pearsonR -r poisson_noise -i  elutions/processed_elutions/*.wide
python 5/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv -f spearmanR -r poisson_noise -i  elutions/processed_elutions/*.wide
python 5/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv -f euclidean -r poisson_noise -i  elutions/processed_elutions/*.wide
python 5/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv -f braycurtis -r poisson_noise -i  elutions/processed_elutions/*.wide
