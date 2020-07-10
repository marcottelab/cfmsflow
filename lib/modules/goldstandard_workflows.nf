#!/usr/bin/env nextflow

include { split_traintest } from './goldstandard_processes'
include { get_negatives_from_observed } from './goldstandard_processes'
include { limit_negatives } from './goldstandard_processes'
include { get_cv_groups } from './goldstandard_processes'



// Calculate correlation and distance-based features
workflow format_goldstandards {

  take: goldstandard_complexes
  take: featmat

  main:

    split_traintest(goldstandard_complexes)

 
    postrain = split_traintest.out.postrain
    postest = split_traintest.out.postest
    postraincomplexes= split_traintest.out.postraincomplexes
    postestcomplexes= split_traintest.out.postestcomplexes


    if(params.negatives_from_observed == false){
        negtrain = split_traintest.out.negtrain
        negtest = split_traintest.out.negtest
     }

    else if( params.negatives_from_observed == true){
       get_negatives_from_observed(featmat, postrain, postest)
       negtrain = get_negatives_from_observed.out.negtrain
       negtest = get_negatives_from_observed.out.negtest
     }

    if(params.negative_limit){
   
        limit_negatives(negtrain, negtest)
        negtrain = limit_negatives.out.negtrain
        negtest = limit_negatives.out.negtest
    }    

     
    traincomplexgroups = get_cv_groups(postrain, postraincomplexes, negtrain)


  emit:
    postrain 
    negtrain
    postest
    negtest
    traincomplexgroups

}


