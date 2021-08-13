#!/bin/bash -l
#SBATCH --job-name=controls
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/cont_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/cont_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
#SBATCH --time=0:30:00
sed -i '1i'"${SLURM_JOB_ID} : job1b_select_controls.sh : $(date)" "/cellar/users/snwright/Data/SlurmOut/track_slurm.txt"

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
CONFIG=$1
FILE_SUFF=$2
CONTROL_PER=$3
ICD10_FILE=$4 # /nrnb/ukb-majithia/epilepsy/inputs/any_icd10_sorted.txt
EXCLUDE_PATT=$5

source ${script_path}Configs/$CONFIG ""

echo ${SLURM_JOB_ID}" : job1b_select_controls.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : job1b_select_controls.sh : "$(date) >> \
	${outDir}${baseName}.track


# create the controls.keepID file
source ${script_path}select_controls.sh $CONFIG 1 $FILE_SUFF $CONTROL_PER $ICD10_FILE $EXCLUDE_PATT


