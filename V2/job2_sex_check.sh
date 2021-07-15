#!/bin/bash -l
#SBATCH --job-name=sex_check
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/sx1_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/sx1_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --mem-per-cpu=16G
#SBATCH --time=2:00:00
sed -i '1i'"${SLURM_JOB_ID} : job2_sex_check.sh : $(date)" "/cellar/users/snwright/Data/SlurmOut/track_slurm.txt"

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1
out_suff=$2
#out=$v1_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_JOB_ID}.out

### Add updated phenotype ###

#source ${script_path}update_phenotype.sh $config $CHR
#source ${script_path}combine_sex.sh $config "" $out

source ${script_path}Configs/$config ""

echo "------------------------------>Performing Sex Check<-------------------------"


if [ $sexInfo -eq 1 ]
then
	source ${script_path}sex_check.sh $config $out_suff
else
	echo "Sex check turned off by RunConfig.conf"
fi

rm ${outDir}${baseName}*.log
rm ${outDir}${baseName}*.nosex
rm ${outDir}${baseName}*temp*
rm ${outDir}${baseName}*.sex_split.*
rm ${outDir}${baseName}*.sex_prune.*
