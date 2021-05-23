#!/bin/bash -l
#SBATCH --job-name=relate
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/relate_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/relate_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=64G
#SBATCH --time=8:00:00
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/
#chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
config=$1
#CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}
out=$v1_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_JOB_ID}.out

source ${script_path}relate1_ibd.sh $config 1 $out
xy
source ${script_path}relate2_indiv_ibd.sh $config all $out

#echo "############################ Prune 2 COMPLETED ##########################"

source ${script_path}relate3_pca.sh $config all no_close_relatives

# echo "############################ Prune 4 COMPLETED ##########################"

