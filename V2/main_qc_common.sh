#!/bin/bash -l
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1
source ${script_path}Configs/$config ""
ids=${outDir}${baseName}.main.jobIDs
> $ids
##TODO get all outputs to their own folder? based on baseName?

parallel=/cellar/users/snwright/.conda/envs/Command/bin/parallel
export parallel
export config
export script_path

## Update phenotypes -----------------
echo "Submitting Job1a"
job1a=$(sbatch job1a_update_phenotype.sh $config)
echo "Job1a: " $job1a >> $ids

## Select controls -------------------
echo "Submitting Job1b"
job1b=$(sbatch --dependency=afterany:$job1a job1b_select_controls.sh $config)
echo "Job1b: " $job1b >> $ids

## Sex check --------
echo "Submitting Job2"
job2=$(sbatch --dependency=afterany:$job1a job2_sex_check.sh $config 0)
echo "Job2: " $job2 >> $ids

## PreLD ------------
echo "Submitting Job3a"
job3a=$(sbatch --dependency=afterany:$job1b:$job2 job3a_missingness.sh $config)
echo "Job3a: " $job3a >> $ids

echo "Submitting Job3b"
job3b=$(sbatch --dependency=afterany:$job3a job3b_missing_indiv.sh $config)
echo "Job3b: " $job3b >> $ids

echo "Submitting Job3c"
job3c=$(sbatch --dependency=afterany:$job3b job3c_preLD.sh $config)
echo "Job3c: " $job3c >> $ids

## LD -------------
echo "Submitting Job4a"
job4a=$(sbatch --dependency=afterany:$job3c job4a_LD.sh $config)
echo "Job4a: " $job4a >> $ids

echo "Submitting Job4b"
job4b=$(sbatch --dependency=afterany:$job4a job4b_post_LD_combine.sh $config)
echo "Job4b: " $job4b >> $ids

## Relatedness ----
echo "Submitting Job5a"
job5a=$(sbatch --dependency=afterany:$job4b job5a_make_king.sh $config)
echo "Job5a: " $job5a >> $ids

echo "Submitting Job5b"
job5b=$(sbatch --dependency=afterany:$job5a job5b_king_cutoff.sh $config)
echo "Job5b: " $job5b >> $ids

## PCA ------------
echo "Submitting Job6"
job6=$(sbatch --dependency=afterany:$job5b job6_pca.sh $config)
echo "Job6: " $job6 >> $ids

## Pre-association
echo "Submitting Job7"
job7=$(sbatch --dependency=afterany:$job6 job7_prep_assoc.sh $config SAIGE 1)
echo "Job7: " $job7 >> $ids

echo "Submitting compilation"
jobcompile=$(sbatch --dependency=afterany:$job6 compile_plots.sh $config qc)
echo "Compile: " $jobcompile >> $ids

echo "All jobs submitted"

job_list="$job1a $job1b $job2 $job3a $job3b $job3c $job4a $job4b $job5a $job5b $job6 $job7 $jobcompile"

job_end=$(sbatch --dependency=afterany:$jobcompile:$job7 job_end.sh $config qc "$job_list")
echo "Summary: " $job_end >> $ids

cat $ids

echo $job_list


# rm ${outDir}${baseName}chrX.sexcheck.png
# rm ${outDir}${baseName}*.missingness.png
