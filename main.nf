#!/usr/bin/env nextflow

// DSL2
nextflow.preview.dsl=2
version = '1.0'
 
/* 
 * Command line input parameter 
 */

// include helper functions
include { complete_message } from './lib/params/messages'
include { error_message } from './lib/params/messages'



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
 * SET UP PARAMETERS
 */


// Very slightly modifies from hlatyping to not access config directly (deprecated)
// The path to the parameter json with definitions is a parameter
paramsWithUsage = readParamsFromJsonSettings(params)


// Show help message
if (params.help){
    helpMessage(paramsWithUsage)
    exit 0
}


// CDM new process, mini argparse checks for type and for choices
errors = validate_params(params, paramsWithUsage)

if (errors){
  
  println errors
  exit 0

}


workflow {


     ////   Get or load features (entrypoint = 1 to start with elution profiles, entrypoint = 2 to load)    
     if (params.entrypoint == 1) {
         features = cfmsinfer_corr()
     }
     else if (params.entrypoint == 2) {
         features_path = params.input_dir + "/" + params.features_entrypoint2
         Channel
          .fromPath( features_path, checkIfExists: true )
          .set { features }    
         features = features.collect()

     }


     ////   Get or load feature matrix ( entrypoint = 3 to load) 
     if (params.entrypoint <=2 && params.exitpoint >= 2) {
         featmat = build_featmat(features)
     }
     else if (params.entrypoint == 3){
          featmat = file(params.feature_matrix_entrypoint3)
     }


     //// Get or load gold standards (generate_labels = true to generate)
     if (params.exitpoint >= 2 && params.generate_labels == true){
         labels = format_goldstandards(file(params.goldstandard_complexes), featmat)
         postrain = labels[0]
         negtrain = labels[1]
         postest = labels[2]
         negtest = labels[3]

     }
     else {
         postrain = file(params.postrain)
         negtrain = file(params.negtrain)
         postest = file(params.postest)
         negtest = file(params.negtest)
     }



     //// Get or load labeled feature matrix ( entrypoint = 4 to load)
     if (params.entrypoint <= 3 && params.exitpoint >= 3) {
         featmat_labeled = label_featmat(featmat, postrain, negtrain)
     }

     // Add warning if only positive or negative labels found

     else if (params.entrypoint == 4){
          featmat_labeled = file(params.feature_matrix_entrypoint4)

     }



     //// Get or load scored interactions ( entrypoint = 5 to load)
     if (params.entrypoint <= 4 && params.exitpoint >=4) {

         featmat_labeled1 = get_labeled_rows(featmat_labeled)
         scored_interactions = training(featmat_labeled1, featmat) 
     }
     else if(params.entrypoint == 5){

         scored_interactions = file(params.scored_interactions_entrypoint5)

     }

     //// Cluster scored interactions
     if (params.exitpoint == 5) {    
         precisionrecall = cfmsinfer_eval(scored_interactions, postrain, negtrain, postest, negtest)  
         scorethreshold = get_fdr_threshold(precisionrecall[0])
         clustering = cluster(scored_interactions, scorethreshold[0])
    }


}




workflow.onComplete {
  complete_message(params, workflow, version)
}

workflow.onError {
  error_message(workflow)
}








