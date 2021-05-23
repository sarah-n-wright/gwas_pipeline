#!/bin/bash -l
#SBATCH --job-name=prune
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/prune_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/prune_%A_%a.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=2:00:00
#SBATCH --array=0-23
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
#chromosomes=(21)
config=$1
CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}
suff=$2

source ${script_path}LD_prune_array.sh $config $CHR $suff

#echo "############################ Prune 1 COMPLETED ##########################"

