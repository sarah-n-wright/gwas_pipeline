#!/bin/bash -l
#SBATCH --job-name=exome_QC
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/exome_QC/v1_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/exome_QC/v1_%A_%a.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=2:00:00
#SBATCH --array=0-23
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
#chromosomes=(21)
config=$1
CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}
out=$v1_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_JOB_ID}.out

### Add updated phenotype ###
# ---> now run independently ----
#source ${script_path}update_phenotype.sh $config $CHR

#source ${script_path}a1_sex_combine.sh $config $CHR $out
# <------------------------------

source ${script_path}a2_sex_check.sh $config $CHR

# echo "############################ GWAS 1 COMPLETED ##########################"

#source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/gwas_2_missingness.sh $config $CHR $out

#echo "############################ GWAS 2 COMPLETED ##########################"

#source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/gwas_3_check_missing_hwe.sh $config $CHR $out

#echo "############################ GWAS 3 COMPLETED ##########################"

#source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/gwas_4_prune_LD.sh $config $CHR $out

#echo "############################ GWAS 4 COMPLETED ##########################"

