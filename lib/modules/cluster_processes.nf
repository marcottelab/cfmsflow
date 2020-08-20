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

  # Get column number that contains the FDR
  fdr_colnum=`head -1 $precisionrecall | tr ',' '\n' | grep -n "FDR" | cut -d':' -f1`

  # Get column number that contains the threshold
  threshold_colnum=`head -1 $precisionrecall | tr ',' '\n' | grep -n "threshold" | cut -d':' -f1`

  score=`grep 'test' $precisionrecall | awk -F"," -v fdr_colnum=\$fdr_colnum -v threshold_colnum=\$threshold_colnum '\$fdr_colnum>=$params.fdr_cutoff {print \$threshold_colnum}' | tail -1`
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
  echo \$R_LIBS_SITE

  

  export LD_LIBRARY_PATH="\$(python -m rpy2.situation LD_LIBRARY_PATH)"
  #:\${LD_LIBRARY_PATH}

  echo \$LD_LIBRARY_PATH

  R -e 'library("dplyr")'

  R -e 'library("igraph")' 

  python ${params.protein_complex_maps_dir}/protein_complex_maps/postprocessing_util/diffusion_clustering.py --input_edges $scored --threshold $scorethreshold --method walktrap --use_scores --outfile clustering --header --id_cols ID --id_sep ' ' --weight_col P_1  --steps $params.walktrap_steps --input_elution $elution_file --annotation_file $annotation_file 

  """
}


