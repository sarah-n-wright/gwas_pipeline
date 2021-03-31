#!/bin/bash -l
#SBATCH --job-name=test
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/test_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/test_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=16:00:00
#SBATCH --array=0

config=TestConfig.conf
#chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 'X' 'Y')
#chromosomes=(16)
#CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}
CHR=''
out=/cellar/users/snwright/Data/SlurmOut/test_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out

source /cellar/users/snwright/Git/gwas_pipeline/gwas_1_common_snps.sh $config $CHR $out

echo "############################ GWAS 1 COMPLETED ##########################"

source /cellar/users/snwright/Git/gwas_pipeline/gwas_2_missingness.sh $config $CHR

echo "############################ GWAS 2 COMPLETED ##########################"

source /cellar/users/snwright/Git/gwas_pipeline/gwas_3_check_missing_hwe.sh $config $CHR

echo "############################ GWAS 3 COMPLETED ##########################"

source /cellar/users/snwright/Git/gwas_pipeline/gwas_4_prune_LD.sh $config $CHR

echo "############################ GWAS 4 COMPLETED ##########################"

