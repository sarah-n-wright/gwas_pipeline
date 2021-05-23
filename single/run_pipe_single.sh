#!/bin/bash -l
#SBATCH --job-name=snp_QC
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/test/pipe_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/test/pipe_%A_%a.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=4:00:00
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/
CHR=""
config=$1

### Add updated phenotype ###
# ---> now run independently ----
#source ${script_path}update_phenotype.sh $config $CHR

#source ${script_path}a1_sex_combine.sh $config $CHR $out
# <------------------------------

source ${script_path}a1_sex_clean.sh $config $CHR

# echo "############################ GWAS 1 COMPLETED ##########################"

source ${script_path}b1_missingness.sh $config $CHR
source ${script_path}b2_miss_case_control.sh $config $CHR

#echo "############################ GWAS 2 COMPLETED ##########################"

source ${script_path}c1_hwe.sh $config $CHR

#echo "############################ GWAS 3 COMPLETED ##########################"

source ${script_path}d1_invariant.sh $config $CHR


#echo "############################ GWAS 4 COMPLETED ##########################"

