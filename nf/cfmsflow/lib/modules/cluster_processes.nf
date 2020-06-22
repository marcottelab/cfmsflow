#!/usr/bin/env nextflow

// Split into test and train
process get_fdr_threshold {

  // copy input file to work directory
  scratch false

  tag { getFDRthreshold }

  input:
  path precisionrecall
  val FDR_CUTOFF

  output:
  stdout()
  path "scorethreshold.txt"


  script:
  """
  # Get the score where FDR is at desired threshold
  # TODO: Add assert to header here
  score=`grep 'test' $precisionrecall | awk -F"," '\$NF>=$FDR_CUTOFF {print \$5}' | tail -1`
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
  val final_params

  output:
  path "clustering.csv"


  script:
  """
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/postprocessing_util/diffusion_clustering.py --input_edges $scored --threshold $scorethreshold --method walktrap --use_scores --outfile clustering --header --id_cols ID --id_sep ' ' --weight_col P_1  --steps $final_params.walktrap_steps 

  """
}


