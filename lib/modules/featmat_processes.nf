#!/usr/bin/env nextflow
// Build feature matrix from calculated features
process build_featmat {


  // Don't copy input file to work directory
  scratch false

  tag { features }

  input:
  file features

  publishDir "${params.output_dir}", mode: 'link'

  output:
  path "featmat"

  script:

  """
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/features/build_feature_matrix.py --input_pairs_files $features --store_interval 10 --output_file featmat --sep ','

  """
}

// Label feature matrix
process label_featmat {

  // Don't copy input file to work directory
  scratch false

  tag { featmat_labeling }

  input:
  path featmat
  path positives
  path negatives

  publishDir "${params.output_dir}", mode: 'link'

  output:
  path "featmat_labeled"

  script:

  """

  head $positives
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/features/add_label.py --input_feature_matrix $featmat --input_positives $positives --input_negatives $negatives --sep , --ppi_sep ' ' --id_column ID --output_file featmat_labeled --fillna 0 --id_sep ' ' 
  """
}

// Get labeled rows
process get_labeled_rows {

  // Don't copy input file to work directory
  scratch false

  tag { get_labeled_rows }

  input:
  path featmat_labeled

  publishDir "${params.output_dir}", mode: 'link'

  output:
  path "featmat_labeled1"

  script:

  """
  grep -v ",0.0\$" $featmat_labeled > featmat_labeled1

  """
}











