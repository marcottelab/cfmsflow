include check_mandatory_parameter from './params_utilities'

// Add something that checks that numeric ones are numeric
def check_params(Map params, String version) { 

    // set up input directory

    final_params = params

    def input_dir = check_mandatory_parameter(params, 'input_dir') - ~/\/$/

    //  check a pattern has been specified
    def elution_pattern = check_mandatory_parameter(params, 'elution_pattern')

    // set up output directory
    final_params.output_dir = check_mandatory_parameter(params, 'output_dir') - ~/\/$/


    final_params.elutions_path = input_dir + "/" + elution_pattern

    final_params.feature_matrix = file(params.feature_matrix)
    //final_params.goldstandard = file(params.goldstandard_complexes)

    // Add check for numeric
    //final_params.MERGE_THRESHOLD = params.merge_threshold
    //final_params.COMPLEX_SIZE_THRESHOLD = params.complex_size_threshold
    //final_params.NEGATIVES_FROM_OBSERVED = params.negatives_from_observed
    ///final_params.NEGATIVE_LIMIT=params.negative_limit
    //final_params.classifiers_to_scan = params.classifiers_to_scan
    //final_params.GENERATIONS = params.generations
    //final_params.POPULATION = params.population
    //final_params.N_JOBS = params.n_jobs
     
    //final_params.WALKTRAP_STEPS = params.walktrap_steps
    //final_params.annotation_file = params.annotation_file
    //final_params.elution_file = params.elution_file

    //final_params.FDR_CUTOFF = params.fdr_cutoff
    //final_params.plot_pr = params.plot_pr

    // final_params.pos_train = file(params.pos_train)
    // final_params.neg_train = file(params.neg_train)


    return final_params
}


