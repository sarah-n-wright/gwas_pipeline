#!/bin/bash -l
#SBATCH --job-name=pheno
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/exome_QC/pheno_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/exome_QC/pheno_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=1:00:00
#SBATCH --array=0-25
script_path=/cellar/users/snwright/Git/gwas_pipeline/
config=$1
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y' 'XY' 'MT')
#chromosomes=(19)
CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}
out=$pheno_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_JOB_ID}.out

### Add updated phenotype ###

source ${script_path}update_phenotype.sh $config $CHR

