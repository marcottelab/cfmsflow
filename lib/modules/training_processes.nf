#!/usr/bin/env nextflow
// Build feature matrix from calculated features
process cfmsinfer_scan {

  // Don't copy input file to work directory
  scratch false

  tag { scan_parameters }

  publishDir "${params.output_dir}", mode: 'link'

  input:
  path featmat_labeled1


  output:
  path "pipeline.py"
  


  script:

  """
  SELECTORS_FORMATTED=\$(cat $params.selectors_to_scan | tr '\n' ' ')
  TRANSFORMERS_FORMATTED=\$(cat $params.transformers_to_scan | tr '\n' ' ')
  CLASSIFIERS_FORMATTED=\$(cat $params.classifiers_to_scan | tr '\n' ' ')
  
  echo \$SELECTORS_FORMATTED
  echo \$TRANSFORMERS_FORMATTED
  echo \$CLASSIFIERS_FORMATTED
  echo $params.tpot_template

  mkdir tpot.tmp
  python $params.tpot_dir/train_TPOT.py --training_data featmat_labeled1 --outfile pipeline.py --template $params.tpot_template --selector_subset \$SELECTORS_FORMATTED --transformer_subset \$TRANSFORMERS_FORMATTED --classifier_subset \$CLASSIFIERS_FORMATTED --id_cols 0 --n_jobs $params.n_jobs --generations $params.generations --population_size $params.population --labels -1 1 --temp_dir training/tpot.tmp

  """
}

process cfmsinfer_train {
// Train with parameters from scan

  // Don't copy input file to work directory
  scratch false

  tag { train_model }

  publishDir "${params.output_dir}", mode: 'link'

  input:
  path pipeline
  path featmat_labeled1

  output:
  path "tpot_fitted_model.p"
  path "tpot_fitted_model.p.txt"
  path "tpot_fitted_model.p.featureimportances"

  script:
  """
  python $params.tpot_dir/train_test_model2.py --training_infile $featmat_labeled1 --exported_pipeline $pipeline --id_cols 0 --output_basename tpot
  """
}


// Apply model to all interactions
process cfmsinfer_score {

  // Don't copy input file to work directory
  scratch false

  tag { apply_model }

  publishDir "${params.output_dir}", mode: 'link'
  input:
  path model
  path featmat

  output:
  path "scored_interactions"
  
  // Changed to be named output
  script:

  """
  touch tpot_fitted_model.p.txt
  touch tpot_fitted_model.p.featureimportances

  python $params.tpot_dir/tpot_predict.py --datafile $featmat --serialized_model $model --outfile scored_interactions --id_cols 0

  """
}



