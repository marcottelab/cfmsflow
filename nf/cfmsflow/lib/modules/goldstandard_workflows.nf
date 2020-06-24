#!/usr/bin/env nextflow

include { split_traintest } from './goldstandard_processes'
include { get_negatives_from_observed } from './goldstandard_processes'
include { limit_negatives } from './goldstandard_processes'

// Calculate correlation and distance-based features
workflow format_goldstandards {

  take: featmat
  take: final_params

  main:

    split_traintest(final_params)

 
    postrain = split_traintest.out.postrain
    postest = split_traintest.out.postest


    if(final_params.negatives_from_observed == false){
        negtrain = split_traintest.out.negtrain
        negtest = split_traintest.out.negtest
     }

    else if( final_params.negatives_from_observed == true){
       get_negatives_from_observed(featmat, postrain, postest, final_params)
       negtrain = get_negatives_from_observed.out.negtrain
       negtest = get_negatives_from_observed.out.negtest
     }

    if(final_params.negative_limit){
   
        limit_negatives(negtrain, negtest, final_params)
        negtrain = limit_negatives.out.negtrain
        negtest = limit_negatives.out.negtest
    }    

   


  emit:
    postrain 
    negtrain
    postest
    negtest


}


