#!/bin/bash -l
## Minimum files needed to complete:
#1# {base}combined.LD_pruned.bim/bed/fam OR {base}combined.final./bim/bed/fam
#1# {base}.imp.phe.cov OR {base}.final.phe.cov
#2# imputation files OR {out}.final.bgen/bgi
#2# {out}.saige.sample

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
#=$0 activate RSAIGE2 environment; CHECK PCS
config=$1
out_suff=$2 # default "", include _
do_step_1=$3 # 1 for yes
source ${script_path}Configs/$config ""
ids=${outDir}${baseName}.saige$out_suff.jobIDs
> $ids
##TODO get all outputs to their own folder? based on baseName?

parallel=/cellar/users/snwright/.conda/envs/Command/bin/parallel
export parallel
export config
export script_path

#conda activate RSAIGE2

if [ $do_step_1 -eq 1 ]; then
  ## Run SAIGE Step 1 -----------------
  echo "Submitting Step 1"
  step1=$(sbatch run_saige.sh $config 1 1 $out_suff)
  echo "Step1: " $step1 >> $ids

  ## Run SAIGE Step 2 ----------------
  echo "Submitting Step 2"
  step2=$(sbatch --dependency=afterany:$step1 run_saige_step2.sh $config 1 $out_suff)
  echo "Step2: " $step2 >> $ids

elif [ $do_step_1 -eq 0 ]; then
  ## Run SAIGE Step 2 ----------------
  echo "Submitting Step 2"
  step2=$(sbatch run_saige_step2.sh $config 1 $out_suff)
  echo "Step2: " $step2 >> $ids
else
  echo "Please specify 'do_step_1'"

fi


## Combine stats files -------------------
echo "Submitting Job8a"
job8a=$(sbatch --dependency=afterany:$step2 job8a_post_assoc.sh $config SAIGE imputed $out_suff)
echo "Job8a: " $job8a >> $ids

## Plot results --------
source /cellar/users/snwright/anaconda3/bin/activate Command
which python

echo "Submitting Job8b"
job8b=$(sbatch --dependency=afterany:$job8a job8b_results_plot.sh $config SAIGE combined.IMP$out_suff.stats $out_suff)
echo "Job8b: " $job8b >> $ids

echo "All jobs submitted"

job_list="$step1 $step2 $job8a $job8b"

job_end=$(sbatch --dependency=afterany:$job8b job_end.sh $config saige "$job_list")
echo "Summary: " $job_end >> $ids

cat $ids

echo $job_list


