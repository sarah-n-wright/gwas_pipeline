#!/bin/bash -l
#SBATCH --job-name=LD
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/ld_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/ld_%A_%a.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --time=2:00:00
#SBATCH --array=0-23

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1

chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
chr=${chromosomes[$SLURM_ARRAY_TASK_ID]}

source ${script_path}LD_prune_array.sh $config $chr
