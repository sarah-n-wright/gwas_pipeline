#!/bin/bash -l
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1
CONTROL_PER=$2
ICD10_FILE=/nrnb/ukb-majithia/epilepsy/inputs/any_icd10_sorted.txt
EXCLUDE_PATT=$3
skip_MAF=$4

##TODO
	# fix inputs to be in config
	# get all outputs to their own folder? based on baseName?


parallel=/cellar/users/snwright/.conda/envs/Command/bin/parallel
export parallel
export config
export script_path

## Update phenotypes -----------------
#$parallel ./par1a_updated_phenotype.sh ::: ${chromosomes[@]}
job1a=$(sbatch job1a_update_phenotype.sh $config)
echo "Job 1 submitted: " $job1a

## Select controls -------------------
job1b=$(sbatch --dependency=afterany:$job1a job1b_select_controls.sh \
	$config $CONTROL_PER $EXCLUDE_PATT)
echo "Job1b: " $job1b
#source ${script_path}select_controls.sh $CONFIG 1 updated_phe $CONTROL_PER $ICD10_FILE

## Sex check --------
job2=$(sbatch --dependency=afterany:$job1a job2_sex_check.sh $config 0)
echo "Job2: " $job2

## PreLD ------------
job3a=$(sbatch --dependency=afterany:$job1b:$job2 job3a_missingness.sh $config)
echo "Job3a: " $job3a

job3b=$(sbatch --dependency=afterany:$job3a job3b_missing_idv.sh $config)
echo "Job3b: " $job3b

job3c=$(sbatch --dependency=afterany:$job3b job3c_preLD.sh $config $skip_MAF)
echo "Job3c: " $job3c

## LD -------------
job4a=$(sbatch --dependency=afterany:$job3c job4a_LD.sh $config)
echo "Job4a: " $job4a

job4b=$(sbatch --dependency=afterany:$job4a job4b_post_LD_combine.sh $config)
echo "Job4b: " $job4b

## Relatedness ----
job5a=$(sbatch --dependency=afterany:$job4b job5a_make_king.sh $config)
echo "Job5a: " $job5a

job5b=$(batch --dependency=afterany:$job5a job5b_king_cutoff.sh $config)
echo "Job5b: " $job5b

## PCA ------------
job6=$(sbatch --dependency=afterany:$job5b job6_pca.sh $config)
echo "Job6: " $job6

## Pre-association
job7=$(sbatch --dependency=afterany:$job6 job7_prep_assoc.sh $config SAIGE 1)
echo "Job7: " $job7

### THESE SHOULD BE INDEPENDENT JOBS?? Then I wouldn't actually need to parallelize?

