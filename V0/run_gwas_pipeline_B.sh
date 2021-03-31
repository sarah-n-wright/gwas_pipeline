#!/bin/bash -l
#SBATCH --job-name=snp_qc_sex
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/snpchip_QC/sex_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/snpchip_QC/sex_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=4:00:00
#SBATCH --array=0

config=SNP_QC_config.conf
#chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 'X' 'Y' 'XY' 'MT')
chromosomes=(16)
CHR=${chromosomses[$SLURM_TASK_ARRAY_ID]}
source /cellar/users/snwright/Git/gwas_pipeline/V0/gwas_sex_combine.sh $config ''

echo "############################ GWAS 5a COMPLETED##########################"

source /cellar/users/snwright/Git/gwas_pipeline/V0/gwas_5_sex.sh $config $CHR

#echo "############################ GWAS 5 COMPLETED ##########################"

#source /cellar/users/snwright/Git/gwas_pipeline/V0/gwas_6_ibd.sh $config $CHR

#echo "############################ GWAS 6 COMPLETED ##########################"

# source /cellar/users/snwright/Git/gwas_pipeline/V0/gwas_7_pca.sh $config
