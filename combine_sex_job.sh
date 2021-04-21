#!/bin/bash -l
#SBATCH --job-name=$1
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/snpchip_QC/combXY_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/snpchip_QC/combXY_%A.err
#SBATCH --mem-per-cpu=32G
#SBATCH --time=8:00:00
#SBATCH --array=0
script_path=/cellar/users/snwright/Git/gwas_pipeline/
config=$1

out=$v1_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_JOB_ID}.out

### Add updated phenotype ###

#source ${script_path}update_phenotype.sh $config $CHR

source ${script_path}combine_sex.sh $config "" $out


# echo "############################ GWAS 1 COMPLETED ##########################"

#source /cellar/users/snwright/Git/gwas_pipeline/gwas_2_missingness.sh $config $CHR $out

#echo "############################ GWAS 2 COMPLETED ##########################"

#source /cellar/users/snwright/Git/gwas_pipeline/gwas_3_check_missing_hwe.sh $config $CHR $out

#echo "############################ GWAS 3 COMPLETED ##########################"

#source /cellar/users/snwright/Git/gwas_pipeline/gwas_4_prune_LD.sh $config $CHR $out

#echo "############################ GWAS 4 COMPLETED ##########################"

