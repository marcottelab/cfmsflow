#!/usr/bin/env nextflow

// DSL2
nextflow.preview.dsl=2
version = '1.0'
 
/* 
 * Command line input parameter 
 */

// include helper functions
include { version_message } from './lib/params/messages'
include { help_message } from './lib/params/messages'
include { complete_message } from './lib/params/messages'
include { error_message } from './lib/params/messages'


include { default_params } from './lib/params/params_parser'
include { check_params } from './lib/params/params_parser'

include { help_or_version } from './lib/params/params_utilities'

include { cfmsinfer_corr } from './lib/modules/feature_workflows'
include { build_featmat } from './lib/modules/featmat_processes'



// setup params
default_params = default_params()
merged_params = default_params + params

// help and version messages
help_or_version(merged_params, version)

final_params = check_params(merged_params, version)




workflow {

    Channel
      .fromPath( final_params.elutions_path, checkIfExists: true )
      .set { elutions }

    Channel
       .from( "pearsonR", "spearmanR", "euclidean", "braycurtis" )
       .set { corrs }

     elutions.combine(corrs).set { elutions_and_corrs }


     features = cfmsinfer_corr(elutions_and_corrs).collect()
     features | view

     build_featmat(features)
       

}




workflow.onComplete {
  complete_message(final_params, workflow, version)
}

workflow.onError {
  error_message(workflow)
}








