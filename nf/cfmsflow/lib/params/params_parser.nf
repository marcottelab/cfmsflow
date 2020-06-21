include check_mandatory_parameter from './params_utilities'


def default_params(){
    /***************** Setup inputs and channels ************************/
    def params = [:]
    params.help = false
    params.version = false
    params.input_dir = '/project/cmcwhite/pipelines/cfmsinfer/elutions/processed_elutions'
    params.elution_pattern = '*.wide'


    params.feature_matrix = '/project/cmcwhite/pipelines/cfmsinfer/feature_matrix/testrun.featmat'
    params.goldstandard_complexes = '/project/cmcwhite/pipelines/cfmsinfer/accessory_files/allComplexesCore_photo_euktovirNOG_expansion.txt'

    params.merge_threshold=0.6
    params.complex_size_threshold=30
    params.negatives_from_observed=true
    params.negative_limit = 20000

    params.positive_labels = '/project/cmcwhite/pipelines/cfmsinfer/gold_standards/pos_train.txt'
    params.negative_labels =  '/project/cmcwhite/pipelines/cfmsinfer/gold_standards/neg_train.txt'
   

    params.classifiers_to_scan = '/project/cmcwhite/pipelines/cfmsinfer/accessory_files/classifier_subset.txt'
    params.generations = 10
    params.population = 20
    params.n_jobs = 20

    params.walktrap_steps = 3
    params.annotation_file = '/project/cmcwhite/pipelines/cfmsinfer/accessory_files/virNOG_collapse_annotations.txt'
    params.elution_file = ''


    params.plot_pr = 'False'
    params.fdr_cutoff = 0.2


    params.output_dir = 'output_dir'
    return params
}

def check_params(Map params, String version) { 

    // Add option to skip plotting prcurve 
    // set up input directory
    def final_params = [:]


    def input_dir = check_mandatory_parameter(params, 'input_dir') - ~/\/$/

    //  check a pattern has been specified
    def elution_pattern = check_mandatory_parameter(params, 'elution_pattern')

    // set up output directory
    final_params.output_dir = check_mandatory_parameter(params, 'output_dir') - ~/\/$/


    final_params.elutions_path = input_dir + "/" + elution_pattern

    final_params.feature_matrix = file(params.feature_matrix)
    final_params.goldstandard = file(params.goldstandard_complexes)

    // Add check for numeric
    final_params.MERGE_THRESHOLD = params.merge_threshold
    final_params.COMPLEX_SIZE_THRESHOLD = params.complex_size_threshold
    final_params.NEGATIVES_FROM_OBSERVED = params.negatives_from_observed
    final_params.NEGATIVE_LIMIT=params.negative_limit
    final_params.classifiers_to_scan = params.classifiers_to_scan
    final_params.GENERATIONS = params.generations
    final_params.POPULATION = params.population
    final_params.N_JOBS = params.n_jobs
     
    final_params.WALKTRAP_STEPS = params.walktrap_steps
    final_params.annotation_file = params.annotation_file
    final_params.elution_file = params.elution_file

    final_params.FDR_CUTOFF = params.fdr_cutoff
    final_params.plot_pr = params.plot_pr

    // final_params.pos_train = file(params.pos_train)
    // final_params.neg_train = file(params.neg_train)


    return final_params
}


