#!/bin/bash -l
#SBATCH --job-name=exome_QC
#SBATCH --output=/celllar/users/snwright/Data/SlurmOut/exome_QC/redo_%A_%a.out
#SBATCH --error=/cellar/users/snwright/Data/SlurmOut/exome_QC/redo_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --partition=nrnb-compute
#SBATCH --mem-per-cpu=32G
#SBATCH --time=16:00:00
#SBATCH --array=0-24

config=Exome_QC_config.conf
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 'X' 'Y')
#chromosomes=(16)
CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}

source scriptDir=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/gwas_1_common_snps.sh $config $CHR

echo "############################ GWAS 1 COMPLETED ##########################"

source scriptDir=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/gwas_2_missingness.sh $config $CHR

echo "############################ GWAS 2 COMPLETED ##########################"

source scriptDir=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/gwas_3_check_missing_hwe.sh $config $CHR

echo "############################ GWAS 3 COMPLETED ##########################"

source scriptDir=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/gwas_4_prune_LD.sh $config $CHR

echo "############################ GWAS 4 COMPLETED ##########################"

