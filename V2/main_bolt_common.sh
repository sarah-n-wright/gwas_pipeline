#!/bin/bash -l
config=$1
out_suff=$2 # default = "", include _ at start
##TODO get all outputs to their own folder? based on baseName?

cd /nrnb/ukb-majithia/
module load bolt-lmm
script_path=sarah/Git/gwas_pipeline/V2/

source ${script_path}Configs/$config ""
outDir=$(echo ${outDir##*ukb-majithia/})
ids=${outDir}${baseName}.bolt$out_suff.jobIDs
> $ids

## prep files -------------
echo "Submitting bolt_prep"
prep=$(sbatch ${script_path}prep_bolt.sh $config)
echo "Prep: " $prep >> $ids


## Run bolt -----------------
echo "Submitting BOLT"
bolt=$(sbatch --dependency=afterany:$prep ${script_path}run_bolt.sh $config 1 $out_suff)
echo "BOLT: " $bolt >> $ids

echo "Job8a not needed."
## Combine stats files -------------------
#echo "Submitting Job8a"
#job8a=$(sbatch --dependency=afterany:$step2 job8a_post_assoc.sh $config BOLT imputed)
#echo "Job8a: " $job8a >> $ids

cd /nrnb/ukb-majithia/$script_path

## Plot results --------
echo "Submitting Job8b"
job8b=$(sbatch --dependency=afterany:$bolt job8b_results_plot.sh $config BOLT .bolt_imp$out_suff.stats.bgen $out_suff)
echo "Job8b: " $job8b >> /nrnb/ukb-majithia/$ids

echo "All jobs submitted"

job_list="$prep $bolt $job8b"

job_end=$(sbatch --dependency=afterany:$job8b job_end.sh $config bolt "$job_list")
echo "Summary: " $job_end >> /nrnb/ukb-majithia/$ids

cat /nrnb/ukb-majithia/$ids

echo $job_list
