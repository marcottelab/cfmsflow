#!/usr/bin/env nextflow

// Split into test and train
process get_fdr_threshold {

  // copy input file to work directory
  scratch false

  tag { getFDRthreshold }

  input:
  path precisionrecall

  publishDir "${params.output_dir}", mode: 'link'

  output:
  stdout()
  path "scorethreshold.txt"


  script:
  """
  # Get the score where FDR is at desired threshold
  # TODO: Add assert to header here
  score=`grep 'test' $precisionrecall | awk -F"," '\$NF>=$params.fdr_cutoff {print \$6}' | tail -1`
  echo \$score > scorethreshold.txt 
  printf \$score
  """
}


// Split into test and train
process cluster {

  // copy input file to work directory
  scratch true

  tag { cluster }

  input:

  path scored
  val scorethreshold
  path annotation_file
  path elution_file

  publishDir "${params.output_dir}", mode: 'link'

  output:
  path "clustering.csv"


  script:
  """
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/postprocessing_util/diffusion_clustering.py --input_edges $scored --threshold $scorethreshold --method walktrap --use_scores --outfile clustering --header --id_cols ID --id_sep ' ' --weight_col P_1  --steps $params.walktrap_steps --input_elution $elution_file --annotation_file $annotation_file 

  """
}


