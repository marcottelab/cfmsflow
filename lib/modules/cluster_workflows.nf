#!/usr/bin/env nextflow

include { cluster } from './cluster_processes'

// Calculate correlation and distance-based features
workflow cluster_interactions {

  take: scored_interactions
  take: scorethreshold

  main:

    if (params.annotation_file){
    annotation_file = file(params.annotation_file)
    }
    else{
    annotation_file = ""
    }

    if (params.elution_file){
    elution_file = file(params.elution_file)
    }
    else{
    elution_file = ""
    }



    clustering = cluster(scored_interactions, scorethreshold, annotation_file, elution_file)


  emit:
    clustering


}


