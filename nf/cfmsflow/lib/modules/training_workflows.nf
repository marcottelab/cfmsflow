#!/usr/bin/env nextflow

include { cfmsinfer_scan } from './training_processes'
include { cfmsinfer_train } from './training_processes'
include { cfmsinfer_score } from './training_processes'

// Calculate correlation and distance-based features
workflow training {

  take: featmat_labeled1
  take: featmat
  take: final_params

  main:

    pipeline = cfmsinfer_scan(featmat_labeled1, final_params) 
    model = cfmsinfer_train(pipeline, featmat_labeled1)

    scored = cfmsinfer_score(model, featmat)

  emit:
    scored

}


