#!/usr/bin/env nextflow

include { corr_process } from './feature_processes'
include { rescale_process } from './feature_processes'
include { alph_process } from './feature_processes'


// Calculate correlation and distance-based features
workflow cfmsinfer_corr {
  take: final_params

  main:
     Channel
      .fromPath( final_params.elutions_path, checkIfExists: true )
      .set { elutions }

    Channel
       .from( "pearsonR", "spearmanR", "euclidean", "braycurtis" )
       .set { corrs }

     elutions.combine(corrs).set { elutions_and_corrs }


    output_corrs = corr_process(elutions_and_corrs, final_params) 
    output_corrs = rescale_process(output_corrs, final_params)
    output_corrs = alph_process(output_corrs, ",", final_params)

    features = output_corrs.collect()

  emit:
    features

}


