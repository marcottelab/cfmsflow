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


include { check_params } from './lib/params/params_parser'

include { readParamsFromJsonSettings } from './lib/params/params_utilities'
include { validate_params } from './lib/params/params_utilities'

include { helpMessage } from './lib/params/params_utilities'
include { cfmsinfer_corr } from './lib/modules/feature_workflows'
include { build_featmat } from './lib/modules/featmat_processes'
include { format_goldstandards} from './lib/modules/goldstandard_workflows' 
include { label_featmat } from './lib/modules/featmat_processes'
include { get_labeled_rows } from './lib/modules/featmat_processes'
include { training } from './lib/modules/training_workflows'
include { cfmsinfer_eval } from './lib/modules/eval_processes'
include { get_fdr_threshold } from './lib/modules/cluster_processes'
include { cluster } from './lib/modules/cluster_processes'


/*
 * SET UP CONFIGURATION VARIABLES
 */

// setup params


final_params = check_params(params, version)

paramsWithUsage = readParamsFromJsonSettings(params)
validate_params(params, paramsWithUsage)
exit 0


// Show help emssage
if (params.help){
    helpMessage(paramsWithUsage)
    exit 0
}



workflow {


     ////   Get or load features (entrypoint = 1 to start with elution profiles, entrypoint = 2 to load)    
     if (final_params.entrypoint == 1) {
         features = cfmsinfer_corr(final_params)
     }
     else if (final_params.entrypoint == 2) {
         Channel
          .fromPath( final_params.features_path, checkIfExists: true )
          .set { features }    

     }


     ////   Get or load feature matrix ( entrypoint = 3 to load) 
     if (final_params.entrypoint <=2 && final_params.exitpoint >= 2) {
         featmat = build_featmat(features, final_params)
     }
     else if (final_params.entrypoint == 3){
          featmat = final_params.feature_matrix_entrypoint3
     }


     //// Get or load gold standards (generate_labels = true to generate)
     if (final_params.exitpoint >= 2 && final_params.generate_labels == true){
         labels = format_goldstandards(featmat, final_params)
         postrain = labels[0]
         negtrain = labels[1]
         postest = labels[2]
         negtest = labels[3]

     }
     else {
         postrain = final_params.postrain
         negtrain = final_params.negtrain
         postest = final_params.postest
         negtest = final_params.negtest
     }



     //// Get or load labeled feature matrix ( entrypoint = 4 to load)
     if (final_params.entrypoint <= 3 && final_params.exitpoint >= 3) {
         featmat_labeled = label_featmat(featmat, postrain, negtrain, final_params)
     }

     else if (final_params.entrypoint == 4){
          featmat_labeled = final_params.feature_matrix_entrypoint4

     }



     //// Get or load scored interactions ( entrypoint = 5 to load)
     if (final_params.entrypoint <= 4 && final_params.exitpoint >=4) {

         featmat_labeled1 = get_labeled_rows(featmat_labeled, final_params)
         scored_interactions = training(featmat_labeled1, featmat, final_params) 
     }
     else if(final_params.entrypoint == 5){

         scored_interactions = final_params.scored_interactions_entrypoint5

     }

     //// Cluster scored interactions
     if (final_params.exitpoint == 5) {    
         precisionrecall = cfmsinfer_eval(scored_interactions, postrain, negtrain, postest, negtest, final_params)  
         scorethreshold = get_fdr_threshold(precisionrecall[0], final_params.fdr_cutoff, final_params)
         clustering = cluster(scored_interactions, scorethreshold[0], final_params)
    }


}




workflow.onComplete {
  complete_message(final_params, workflow, version)
}

workflow.onError {
  error_message(workflow)
}








