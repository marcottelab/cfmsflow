echo "Running first step of pipeline only: example_params_step1"
nextflow main.nf -params-file example_params/example_params_step1.json > .step1.stdout

if [ $? -eq 1 ]
then
   cat .step1.stdout
   echo "Running first step of pipeline failed, see .nextflow.log"
fi


echo "Running second step of pipeline only: example_params_step2.json"
nextflow main.nf -params-file example_params/example_params_step2.json > .step2.stdout

if [ $? -eq 1 ]
then
   cat .step2.stdout
   echo "Running second step of pipeline failed, see .nextflow.log"
fi


echo "Running third step of pipeline only: example_params_step3.json"
nextflow main.nf -params-file example_params/example_params_step3.json > .step3.stdout

if [ $? -eq 1 ]
then
   cat .step3.stdout
   echo "Running third step of pipeline failed, see .nextflow.log"
fi


echo "Running fourth step of pipeline only: example_params_step4.json"
nextflow main.nf -params-file example_params/example_params_step4.json > .step4.stdout

if [ $? -eq 1 ]
then
   cat .step4.stdout
   echo "Running fourth step of pipeline failed, see .nextflow.log"
fi

echo "Running fifth step of pipeline only: example_params_step5.json"
nextflow main.nf -params-file example_params/example_params_step5.json > .step5.stdout

if [ $? -eq 1 ]
then
   cat .step5.stdout
   echo "Running fifth step of pipeline failed, see .nextflow.log"
fi


echo "Running entire pipeline"
nextflow main.nf -params-file example_params/user_params_template.json > .wholepipeline.stdout

if [ $? -eq 1 ]
then
   cat .wholepipeline.stdout
   echo "Running whole pipeline failed, see .nextflow.log"
fi



