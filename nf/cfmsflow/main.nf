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


//include { default_params } from './lib/params/params_parser'
include { check_params } from './lib/params/params_parser'

include { help_or_version } from './lib/params/params_utilities'

include { cfmsinfer_corr } from './lib/modules/feature_workflows'
include { build_featmat } from './lib/modules/featmat_processes'
include { format_goldstandards} from './lib/modules/goldstandard_workflows' 
include { label_featmat } from './lib/modules/featmat_processes'
include { get_labeled_rows } from './lib/modules/featmat_processes'
include { training } from './lib/modules/training_workflows'
include { cfmsinfer_eval } from './lib/modules/eval_processes'
include { get_fdr_threshold } from './lib/modules/cluster_processes'
include { cluster } from './lib/modules/cluster_processes'



// setup params
//default_params = default_params()
//merged_params = default_params + params

// help and version messages
//help_or_version(merged_params, version)

//final_params = check_params(merged_params, version)

help_or_version(params, version)
final_params = check_params(params, version)


workflow {
      

     if (final_params.entrypoint <= 1) {

         features = cfmsinfer_corr(final_params)
     }


     if (final_params.entrypoint <= 2) {
         featmat = build_featmat(features)
     }


     if (final_params.generate_labels == true){
         labels = format_goldstandards(final_params, featmat)
         postrain = labels[0]
         negtrain = labels[1]
         postest = labels[2]
         negtest = labels[3]

     }

     if (final_params.entrypoint <= 3) {
         featmat_labeled = label_featmat(featmat, postrain, negtrain)
     }



     if (final_params.entrypoint <= 4) {
         featmat_labeled1 = get_labeled_rows(featmat_labeled)
         scored_interactions = training(final_params, featmat_labeled1, featmat) 
     }

     if (final_params.entrypoint <= 5) {    
         precisionrecall = cfmsinfer_eval(scored_interactions, postrain, negtrain, postest, negtest)
     }

     // This step should be optional based on presence of FDR_cutoff

     if (final_params.entrypoint <= 6) {    
   
         scorethreshold = get_fdr_threshold(precisionrecall[0], final_params.fdr_cutoff)
         clustering = cluster(scored_interactions, scorethreshold[0], final_params)
    }


}




workflow.onComplete {
  complete_message(final_params, workflow, version)
}

workflow.onError {
  error_message(workflow)
}








