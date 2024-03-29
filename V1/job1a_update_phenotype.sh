#!/bin/bash -l
#SBATCH --job-name=pheno
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/pheno_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/pheno_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=1:00:00
#SBATCH --array=0-25
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/
config=$1
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y' 'XY' 'MT')
#chromosomes=(19)
CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}

source ${script_path}Configs/$1 ""

### Add updated phenotype ###

source ${script_path}update_phenotype.sh $config $CHR $case_list


