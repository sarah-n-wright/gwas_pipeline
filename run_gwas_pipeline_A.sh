#!/bin/bash -l
#SBATCH --job-name=gwas_test
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/gwas/test_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/gwas/test_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=2G
#SBATCH --time=4:00:00
#SBATCH --array=0

source /cellar/users/snwright/Git/examples/GWAS/gwas_1_common_snps.sh

echo "############################ GWAS 1 COMPLETED ##########################"

source /cellar/users/snwright/Git/examples/GWAS/gwas_2_missingness.sh

echo "############################ GWAS 2 COMPLETED ##########################"

source /cellar/users/snwright/Git/examples/GWAS/gwas_3_check_missing_hwe.sh

echo "############################ GWAS 3 COMPLETED ##########################"

source /cellar/users/snwright/Git/examples/GWAS/gwas_4_prune_LD.sh

echo "############################ GWAS 4 COMPLETED ##########################"

