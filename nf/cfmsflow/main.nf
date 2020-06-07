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


params.input_dir = "/project/cmcwhite/pipelines/cfmsinfer/elutions/processed_elutions/"

// Correlate
process corr_process {

  // copy input file to work directory
  scratch false

  publishDir params.input_dir

  tag { elut_id }

  input:
  tuple elut_id,corr 

  output:
  path "${elut_id.baseName}.${corr}.feat" 

  script:
  """
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv -f $corr -o ${elut_id.baseName}.${corr}.feat $elut_id
  """
} 

// Alphabetize id pairs
process alph_process {

  // Don't copy input file to work directory
  scratch true

  tag { feat }

  input:
  path feat

  output:
  path "${feat}.ordered" 

  script:
  """
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/features/alphabetize_pairs2.py --feature_pairs $feat --outfile ${feat}.ordered --sep ',' --chunksize 10

  """
} 


workflow cfmsinfer_corr {
  take: elutions_and_corrs

  main:

    output_corrs = corr_process(elutions_and_corrs) 
    output_corrs = alph_process(output_corrs)

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
       .set { corrs }

     elutions.combine(corrs).set { elutions_and_corrs }

     elutions_and_corrs.subscribe { println it }


      corrs = cfmsinfer_corr(elutions_and_corrs)

      corrs | view

}

workflow.onComplete {
  complete_message(final_params, workflow, version)
}

workflow.onError {
  error_message(workflow)
}








