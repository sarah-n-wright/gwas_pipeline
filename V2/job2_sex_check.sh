#!/bin/bash -l
#SBATCH --job-name=sex_check
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/sx1_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/sx1_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --time=2:00:00

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1
override_thresholds=$2 #1=yes 0=no
minF=$3 # only specify if override_thresholds=1
maxF=$4 # only specify if override_thresholds=1

source ${script_path}Configs/$config ""

echo ${SLURM_JOB_ID}" : job2_sex_check.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : job2_sex_check.sh : "$(date) >> \
	${outDir}${baseName}.track

echo "------------------------------>Performing Sex Check<-------------------------"


if [ $sexInfo -eq 1 ]
then
source ${script_path}sex_check.sh $config $override_thresholds $minF $maxF
else
echo "Sex check turned off by RunConfig.conf"
fi

#rm ${outDir}${baseName}*.log
#rm ${outDir}${baseName}*.nosex
#rm ${outDir}${baseName}*temp*
#rm ${outDir}${baseName}*.sex_split.*
#rm ${outDir}${baseName}*.sex_prune.*
