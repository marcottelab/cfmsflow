#!/usr/bin/env nextflow
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
  val sep 


  output:
  path "${feat}.ordered"  

  script:
  """
  python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/features/alphabetize_pairs2.py --feature_pairs $feat --outfile ${feat}.ordered --sep $sep --chunksize 10

  """
} 

