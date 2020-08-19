#!/usr/bin/env nextflow
// Correlate
process corr_process {

  // copy input file to work directory
  scratch true

  tag { elut_id }

  input:
  tuple file(elut_id),corr 

  publishDir "${params.output_dir}", mode: 'link'

  output:
  tuple file("${elut_id.baseName}.${corr}.feat"),corr

  script:
  """
  if [ $params.add_poisson_noise == 'true' ]
  then
  echo "Poisson noise added"
  python ${params.protein_complex_maps_dir}/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv --normalize row_max -f $corr -o ${elut_id.baseName}.${corr}.feat $elut_id -r poisson_noise -i $params.poisson_reps 
  else

      python ${params.protein_complex_maps_dir}/protein_complex_maps/features/ExtractFeatures/canned_scripts/extract_features.py --format csv --normalize row_max -f $corr -o ${elut_id.baseName}.${corr}.feat $elut_id
  fi

  """
} 

// Invert distance measure scores
process rescale_process {

  // Don't copy input file to work directory
  scratch true

  tag { feat }

  input:
  tuple file(feat),corr 
    
  publishDir "${params.output_dir}", mode: 'link'

  output:
  path "${feat}.*scaled" 


  script:
  if (corr == "euclidean" || corr == "braycurtis")

  """
  python ${params.protein_complex_maps_dir}/protein_complex_maps/features/normalize_features.py --input_feature_matrix $feat --output_filename ${feat}.rescaled --features $corr --min 0 --sep , --inverse

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

  publishDir "${params.output_dir}", mode: 'link'

  output:
  path "${feat}.ordered"  

  script:
  """
  python ${params.protein_complex_maps_dir}/protein_complex_maps/features/alphabetize_pairs_chunks.py --feature_pairs $feat --outfile ${feat}.ordered --sep $sep --chunksize 1000000

  """
} 

