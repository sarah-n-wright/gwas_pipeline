#!/bin/bash -l
#SBATCH --job-name=preLD
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/preLD_%A_%a.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/preLD_%A_%a.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --time=1:00:00
#SBATCH --array=0-23
#sed -i '1i'"${SLURM_JOB_ID} : job3c_preLD.sh : $(date)" "/cellar/users/snwright/Data/SlurmOut/track_slurm.txt"

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
#chromosomes=(21)
config=$1
skip_MAF=$2 # 1 for yes (set max=0.5)
CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}
out=$v1_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_JOB_ID}.out

source ${script_path}Configs/$config ""

if [ $CHR -eq 1 ]; then
echo ${SLURM_ARRAY_JOB_ID}" : job3c_preLD.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_ARRAY_JOB_ID}" : job3c_preLD.sh : "$(date) >> \
        ${outDir}${baseName}.track
fi


source ${script_path}preLD_b2_miss_case_control.sh $config $CHR $out

#echo "############################ Missing CC COMPLETED ##########################"

source ${script_path}preLD_c1_hwe.sh $config $CHR $out

#echo "############################ HWE COMPLETED ##########################"
source ${script_path}preLD_d1_mafFilter.sh $config $CHR $skip_MAF

#echo "############################ MAF filter COMPLETED ##########################"

