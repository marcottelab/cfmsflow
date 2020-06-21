#!/usr/bin/env nextflow

// Split into test and train
process get_FDR_cutoff {

  // copy input file to work directory
  scratch false

  tag { getFDRcutoff }

  input:
  path precisionrecall
  val FDR_CUTOFF

  output:
  stdout()
  path "scoreval.txt"


  script:
  """
  # Get the score where FDR is at desired threshold
  # TODO: Add assert to header here
  score=`grep 'test' $precisionrecall | awk -F"," '\$NF>=$FDR_CUTOFF {print \$5}' | tail -1`
  echo \$score > scoreval.txt 
  echo \$score
  """
}
