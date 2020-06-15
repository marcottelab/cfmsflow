def version_message(String version) {
    println(
        """
        ==============================================
                CFMS-infer Pipeline version ${version}
        ==============================================
        """.stripIndent()
    )
}

def help_message() {
    println(
        """
        Mandatory arguments:

        --input_dir     Path to input dir. This must be used in conjunction with fastq_pattern
        --elution_pattern The regular expression that will match input elution files e.g '*.wide'

        --output_dir    Path to output dir
        --feature_matrix     Path to feature_matrix

        Preset labels:
        --pos_train     Path to input labels	
        --neg_train     asdfasdfa
        --pos_test     Path to input labels	
        --neg_test     asdfasdfa

        Generate labels:
        --goldstandard_complexes File of space separated complexes, one per line
        --merge_threshold MERGE_THRESHOLD Jaccard similarity threshold on which to merge. Default = 0.6
        --complex_size_threshold Size threshold for complexes, throws out complexes larger. Default = 30
        --negatives_from_observed    Create negatives from observed proteins. Default = true 
         --negative_limit Limit the number of negatives in the train an test sest to n. Default = 20000


        Optional aruments:
        --read_polishing_adapter_file path to file containing sequences of adapaters to be trimmed from reads

        """
    )
}

def complete_message(Map params, nextflow.script.WorkflowMetadata workflow, String version){
    // Display complete message
    println ""
    println "Ran the workflow: ${workflow.scriptName} ${version}"
    println "Command line    : ${workflow.commandLine}"
    println "Completed at    : ${workflow.complete}"
    println "Duration        : ${workflow.duration}"
    println "Success         : ${workflow.success}"
    println "Work directory  : ${workflow.workDir}"
    println "Exit status     : ${workflow.exitStatus}"
    println ""
    println "Parameters"
    println "=========="
    params.each{ k, v ->
        if (v){
            println "${k}: ${v}"
        }
    }
}

def error_message(nextflow.script.WorkflowMetadata workflow){
    // Display error message
    println ""
    println "Workflow execution stopped with the following message:"
    println "  " + workflow.errorMessage

}
