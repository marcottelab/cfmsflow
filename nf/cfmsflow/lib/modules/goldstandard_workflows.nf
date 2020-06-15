#!/usr/bin/env nextflow

include { split_traintest } from './goldstandard_processes'
include { alph_process } from './feature_processes'


// Calculate correlation and distance-based features
workflow format_goldstandards {
  take: goldstandard
  take: MERGE_THRESHOLD
  take: COMPLEX_SIZE_THRESHOLD 

  main:

    split_traintest(goldstandard,MERGE_THRESHOLD,COMPLEX_SIZE_THRESHOLD )

 
    labels = alph_process(split_traintest.out.postrain, "'\\t'")
    //labels
    // .class
    // .print
    //split_traintest.out.class
    

    
  //  Channel
    //    .of( labels[0] )
        //.set { labs }
      //  .view()
        //.map { alph_process() }


       // .view()
  emit:
    labels

}


