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


// Correlate
process corr_process {

  // copy input file to work directory
  scratch true

  tag { elut_id }

  input:
  tuple elut_id,corr 

  output:
  // path "${elut_id.baseName}.${corr}.feat" 
  tuple file("${elut_id.baseName}.${corr}.feat"),corr

  script:
  """
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv -f $corr -o ${elut_id.baseName}.${corr}.feat $elut_id
  """
} 

// Invert distance measure scores
process rescale_process {

  // Don't copy input file to work directory
  scratch true

  tag { feat }

  input:
  tuple file(feat),corr 

    
  output:
  path "${feat}.*scaled" 


  script:
  if (corr == "euclidean" || corr == "braycurtis")

  """
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/features/normalize_features.py --input_feature_matrix $feat --output_filename ${feat}.rescaled --features $corr --min 0 --sep , --inverse

  """

  else
  """
  mv $feat ${feat}.unscaled
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


// Calculate correlation and distance-based features
workflow cfmsinfer_corr {
  take: elutions_and_corrs

  main:

    output_corrs = corr_process(elutions_and_corrs) 
    output_corrs = rescale_process(output_corrs)
    output_corrs = alph_process(output_corrs)

  emit:
    output_corrs

}

// Combine features into a feature matrix

//workflow cfmsinfer_build {

//}

// Build feature matrix from calculated features
process build_process {

  // Don't copy input file to work directory
  scratch true

  tag { features }

  input:
  file features

  output:
  path "featmat"  

  script:

  """
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/features/build_feature_matrix.py --input_pairs_files $features --store_interval 10 --output_file featmat --sep ','

  """
} 


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

     build_process(features)
        


}




workflow.onComplete {
  complete_message(final_params, workflow, version)
}

workflow.onError {
  error_message(workflow)
}








