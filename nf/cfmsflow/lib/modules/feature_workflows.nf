#!/usr/bin/env nextflow

include { corr_process } from './feature_processes'
include { rescale_process } from './feature_processes'
include { alph_process } from './feature_processes'


// Calculate correlation and distance-based features
workflow cfmsinfer_corr {
  take: elutions_and_corrs

  main:

    output_corrs = corr_process(elutions_and_corrs) 
    output_corrs = rescale_process(output_corrs)
    output_corrs = alph_process(output_corrs, ",")

  emit:
    output_corrs

}


