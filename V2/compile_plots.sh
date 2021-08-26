#!/bin/bash -l
#SBATCH --job-name=compile
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/compile_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --parsable
#SBATCH --time=2:00:00

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1
stage=$2 # qc or assoc

source ${script_path}Configs/$config ""

echo ${SLURM_JOB_ID}" : compile_plots.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : compile_plots.sh : "$(date) >> \
        ${outDir}${baseName}.track


convert ${outDir}${baseName}chrX.sexcheck.png \
        ${outDir}${baseName}*.missingness.png \
        /cellar/users/snwright/Data/Transfer/v3/${baseName}QC_plots.pdf
# rm ${outDir}${baseName}chrX.sexcheck.png
# rm ${outDir}${baseName}*.missingness.png



