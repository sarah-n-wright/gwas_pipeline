#!/bin/bash -l
#SBATCH --job-name=king
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/king_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/king_%A_%a.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-20
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1

job_id=$SLURM_ARRAY_TASK_ID

source ${script_path}Configs/$1 ""

ld_file=${outDir}${baseName}combined.LD_pruned

echo "------------------------------>Pair-wise IBD<-------------------------"

srun -l plink2 --bfile $ld_file \
        --maf 0.005 \
        --thin-count 50000 \
	--king-table-filter 0.088338 \
        --make-king-table \
        --parallel $job_id 20 \
	--out ${outDir}${baseName}combined


#source ${script_path}relate1_ibd.sh $config 1 $out
#source ${script_path}relate2_indiv_ibd.sh $config all $out

#echo "############################ Prune 2 COMPLETED ##########################"

#source ${script_path}relate3_pca.sh $config all no_close_relatives

# echo "############################ Prune 4 COMPLETED ##########################"

