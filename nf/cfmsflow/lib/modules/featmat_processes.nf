#!/usr/bin/env nextflow
// Build feature matrix from calculated features
process build_featmat {

  // Don't copy input file to work directory
  scratch true

  tag { features }

  input:
  file features

  output:
  path "featmat"

  script:

  """
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/features/build_feature_matrix.py --input_pairs_files $features --store_interval 10 --output_file featmat --sep ','

  """
}
