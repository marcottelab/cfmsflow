#!/usr/bin/env nextflow

// DSL2
nextflow.preview.dsl=2
version = '1.0'
 
/* 
 * Command line input parameter 
 */

// include helper functions
include { version_message } from './lib/messages'
include { help_message } from './lib/messages'
include { complete_message } from './lib/messages'
include { error_message } from './lib/messages'


include { default_params } from './lib/params_parser'
include { check_params } from './lib/params_parser'

include { help_or_version } from './lib/params_utilities'

// setup params
default_params = default_params()
merged_params = default_params + params

// help and version messages
help_or_version(merged_params, version)

final_params = check_params(merged_params, version)

// params.in = "$baseDir/data/sample.fa"


// Correlate
process corr_process {

  // Don't copy input file to work directory
  scratch true

  tag { elut_id }

  input:
  tuple elut_id,metric 

  output:
  file('*head')

  script:
  """

  head ${elut_id}.${corr} > ${elut_id}.head
  """
} 

// Alphabetize id pairs
process alph_process {

  // Don't copy input file to work directory
  scratch true

  tag { elut_id }

  input:
  file elut_id

  output:
  tuple elut_id, file('*test')

  script:
  """
  head -2 $elut_id > ${elut_id}.test
  """
} 


workflow cfmsinfer_corr {
  take: elutions_and_metrics

  main:

    output_corrs = corr_process(elutions_and_metrics) 
    //output_corrs = alph_process(output_corrs)

  emit:
    output_corrs

}


workflow {
    // splitSequences(params.in) | reverse | view

    Channel
      .fromPath( final_params.elutions_path, checkIfExists: true )
      .set { elutions }

    Channel
       .from( "pearsonR", "spearmanR", "euclidean", "braycurtis" )
       .set { metrics }

     elutions.combine(metrics).set { elutions_and_metrics }

     elutions_and_metrics.subscribe { println it }


      corrs = cfmsinfer_corr(elutions_and_metrics)

      corrs | view

}

workflow.onComplete {
  complete_message(final_params, workflow, version)
}

workflow.onError {
  error_message(workflow)
}








