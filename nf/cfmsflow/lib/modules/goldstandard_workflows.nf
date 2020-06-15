#!/usr/bin/env nextflow

include { split_traintest } from './goldstandard_processes'
include { get_negatives_from_observed } from './goldstandard_processes'
include { limit_negatives } from './goldstandard_processes'

// Calculate correlation and distance-based features
workflow format_goldstandards {
  //param: goldstandard
  //param: MERGE_THRESHOLD
  //param: COMPLEX_SIZE_THRESHOLD 
  //param: NEGATIVES_FROM_OBSERVED
  //param: NEGATIVE_LIMIT

  take: final_params
  take: featmat


  main:

    split_traintest(final_params.goldstandard,final_params.MERGE_THRESHOLD,final_params.COMPLEX_SIZE_THRESHOLD )
 
    postrain = split_traintest.out.postrain
    postest = split_traintest.out.postest


    if(final_params.NEGATIVES_FROM_OBSERVED == false){
        negtrain = split_traintest.out.negtrain
        negtest = split_traintest.out.negtest
     }

    else if( final_params.NEGATIVES_FROM_OBSERVED == true){
       get_negatives_from_observed(featmat, postrain, postest)
       negtrain = get_negatives_from_observed.out.negtrain
       negtest = get_negatives_from_observed.out.negtest
     }

    if(final_params.NEGATIVE_LIMIT){
   
        limit_negatives(negtrain, negtest, final_params.NEGATIVE_LIMIT)
        negtrain = limit_negatives.out.negtrain
        negtest = limit_negatives.out.negtest
    }    

   


  emit:
    postrain 
    negtrain
    postest
    negtest


}


