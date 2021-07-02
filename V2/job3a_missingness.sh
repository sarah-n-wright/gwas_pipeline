#!/bin/bash -l
#SBATCH --job-name=preLD
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/preLD_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/preLD_%A_%a.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=4:00:00
#SBATCH --array=0-23
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
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

#source ${script_path}preLD_a1_sex_clean.sh $config $CHR "" #reverse /nrnb/ukb-majithia/epilepsy/outputs/exome/sex_problems.keep_for_now.txt

# echo "############################ GWAS 1 COMPLETED ##########################"

source ${script_path}preLD_b1_missingness.sh $config $CHR $out
# source ${script_path}preLD_b2_miss_case_control.sh $config $CHR $out

