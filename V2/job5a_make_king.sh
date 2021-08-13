#!/bin/bash -l
#SBATCH --job-name=king
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/king_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/king_%A_%a.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=2
#SBATCH --mem=256G
#SBATCH --array=1-200%10
#sed -i '1i'"${SLURM_JOB_ID} : job5a_make_king.sh : $(date)" "/cellar/users/snwright/Data/SlurmOut/track_slurm.txt"

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1

job_id=$SLURM_ARRAY_TASK_ID

source ${script_path}Configs/$1 ""

ld_file=${outDir}${baseName}combined.LD_pruned

if [ $SLURM_ARRAY_TASK_ID -eq 1 ]; then

echo ${SLURM_ARRAY_JOB_ID}" : job5a_make_king.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_ARRAY_JOB_ID}" : job5a_make_king.sh : "$(date) >> \
        ${outDir}${baseName}.track
fi


echo "------------------------------>Pair-wise IBD<-------------------------"

srun -l plink2 --bfile $ld_file \
        --maf 0.005 \
        --thin-count 50000 \
	--king-table-filter 0.088338 \
        --make-king-table \
        --parallel $job_id 200 \
	--out ${outDir}${baseName}combined


#source ${script_path}relate1_ibd.sh $config 1 $out
#source ${script_path}relate2_indiv_ibd.sh $config all $out

#echo "############################ Prune 2 COMPLETED ##########################"

#source ${script_path}relate3_pca.sh $config all no_close_relatives

# echo "############################ Prune 4 COMPLETED ##########################"

