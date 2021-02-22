#!/bin/bash -l
#SBATCH --job-name=gwas_B
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/gwas/test_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/gwas/test_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=2G
#SBATCH --time=4:00:00
#SBATCH --array=0


source /cellar/users/snwright/Git/examples/GWAS/gwas_5_sex.sh

echo "############################ GWAS 5 COMPLETED ##########################"

source /cellar/users/snwright/Git/examples/GWAS/gwas_6_ibd.sh

echo "############################ GWAS 6 COMPLETED ##########################"

source /cellar/users/snwright/Git/examples/GWAS/gwas_7_pca.sh
