#!/usr/bin/env nextflow
// Build feature matrix from calculated features
process cfmsinfer_eval {

  // Don't copy input file to work directory
  scratch true

  tag { eval }

  input:
  path scored
  path postrain
  path negtrain
  path postest
  path negtest

  publishDir "${params.output_dir}", mode: 'link'

  output:
  path "precisionrecall"
  path "precisionrecall.png" optional true
 
  script:

  """

      python ${params.protein_complex_maps_dir}/protein_complex_maps/evaluation/plots/prcurve_cfmsflow.py --results_wprob $scored --input_positives $postrain $postest --input_negatives $negtrain $negtest --labels train test --output_file precisionrecall --id_cols 0 --prob_col 1 --ppi_sep ' ' --results_delim "\t" --labels_delim ' ' --header  --plot False
   
  """
}
