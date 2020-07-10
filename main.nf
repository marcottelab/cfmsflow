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
include { load_features } from './lib/modules/feature_workflows'

include { build_featmat } from './lib/modules/featmat_processes'
include { format_goldstandards} from './lib/modules/goldstandard_workflows' 
include { label_featmat } from './lib/modules/featmat_processes'
include { get_labeled_rows } from './lib/modules/featmat_processes'
include { add_group_column } from './lib/modules/featmat_processes'

include { training } from './lib/modules/training_workflows'
include { cfmsinfer_eval } from './lib/modules/eval_processes'
include { get_fdr_threshold } from './lib/modules/cluster_processes'
include { cluster_interactions } from './lib/modules/cluster_workflows'


/*
 * SET UP PARAMETERS
 */


// Here is where I could filter parameters to only those that need to be used

// Very slightly modifies from hlatyping to not access config directly (deprecated)
// The path to the parameter json with definitions is a parameter
paramsWithUsage = readParamsFromJsonSettings(params)


// Show help message
if (params.help){
    helpMessage(paramsWithUsage)
    exit 0
}


// CDM new process, mini argparse checks for type and for choices
// Potential filter to only steps chosen to run?

errors = validate_params(params, paramsWithUsage)

if (errors){
  
  println errors
  exit 0

}


workflow {

     def user_steps = params.entrypoint..params.exitpoint

     //////////////////////////////////////////////////////
     ////  Get or load features         
     
     // Calculate features from elution profiles
     if ( 1 in user_steps ) {
         features = cfmsinfer_corr()
     }

     // Load existing already generated features
     else if ( params.entrypoint == 2 ) {
         features = load_features()
     }
     ////
     //////////////////////////////////////////////////////


     //////////////////////////////////////////////////////
     ////   Get or load feature matrix 
     if (2 in user_steps){
         featmat = build_featmat(features)
     }
     else if (params.entrypoint == 3 || params.entrypoint == 4){
          featmat = file(params.existing_feature_matrix)
     }
     //else {
     //  println "Entering pipeline at step 3 requires existing_feature_matrix parameter"
     //  System.exit(1)
    // }
     ////
     /////////////////////////////////////////////////////


     ////////////////////////////////////////////////////
     //// Get or load gold standards (generate_labels = true to generate)
       if ( 3 in user_steps || 5 in user_steps ){
  
         if (params.generate_labels == true ){

             labels = format_goldstandards(file(params.goldstandard_complexes), featmat)
             postrain = labels[0]
             negtrain = labels[1]
             postest = labels[2]
             negtest = labels[3]
             traincomplexgroups = labels[4]
         }
         else {
             postrain = file(params.postrain)
             negtrain = file(params.negtrain)
             postest = file(params.postest)
             negtest = file(params.negtest)
 
             traincomplexgroups = file(params.groups)          
             

         }
     }
     ////
     //////////////////////////////////////////////////////

     
     //////////////////////////////////////////////////////
     //// Get or load labeled feature matrix ( entrypoint = 4 to load)
     if ( 3 in user_steps){
         featmat_labeled = label_featmat(featmat, postrain, negtrain)
     }

     // Add warning if only positive or negative labels found

     else if (params.entrypoint == 4){
          featmat_labeled = file(params.existing_feature_matrix_labeled)
     }
     //else {
     //  println "Entering pipeline at step 4 requires existing_feature_matrix_labeled parameter"
     //  System.exit(1)
    // }
     ////
     //////////////////////////////////////////////////////


     //////////////////////////////////////////////////////
     //// Get or load scored interactions ( entrypoint = 5 to load)

     if ( 4 in user_steps ) {
         featmat_labeled1 = get_labeled_rows(featmat_labeled)
         featmat_labeled1 = add_group_column(featmat_labeled1, traincomplexgroups)[0]
         
         scored_interactions = training(featmat_labeled1, featmat) 
     }
     else if(params.entrypoint == 5){

         scored_interactions = file(params.scored_interactions)

     }

     //// Cluster scored interactions

     if ( 5 in user_steps) {
         precisionrecall = cfmsinfer_eval(scored_interactions, postrain, negtrain, postest, negtest)  
         scorethreshold = get_fdr_threshold(precisionrecall[0])

         clustering = cluster_interactions(scored_interactions, scorethreshold[0])
    }


}




workflow.onComplete {
  complete_message(params, workflow, version)
}

workflow.onError {
  error_message(workflow)
}








