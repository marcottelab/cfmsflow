#!/usr/bin/env nextflow

// Correlate
process split_traintest {

  // copy input file to work directory
  scratch false

  tag { goldstandard }

  input:
  path goldstandard
  val MERGE_THRESHOLD
  val COMPLEX_SIZE_THRESHOLD

  output:
  //path "goldstandard_filt"
  file("goldstandard_filt*ppis.txt")

  script:
  """
     python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/preprocessing_util/complexes/complex_merge.py --cluster_filename $goldstandard --output_filename goldstandard_filt.txt --merge_threshold $MERGE_THRESHOLD --complex_size_threshold $COMPLEX_SIZE_THRESHOLD --remove_largest --remove_large_subcomplexes

   # Split complexes to training and test complexes 
   python /project/cmcwhite/github/for_pullreqs/protein_complex_maps/protein_complex_maps/preprocessing_util/complexes/split_complexes.py --input_complexes goldstandard_filt.txt
   echo "did this"

  """
}