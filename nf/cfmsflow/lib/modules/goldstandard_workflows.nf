#!/usr/bin/env nextflow

include { split_traintest } from './goldstandard_processes'
include { alph_process } from './feature_processes'


// Calculate correlation and distance-based features
workflow format_goldstandards {
  take: goldstandard
  take: MERGE_THRESHOLD
  take: COMPLEX_SIZE_THRESHOLD 

  main:

    labels = split_traintest(goldstandard,MERGE_THRESHOLD,COMPLEX_SIZE_THRESHOLD ) 
    labels = alph_process(labels)

  emit:
    labels

}


