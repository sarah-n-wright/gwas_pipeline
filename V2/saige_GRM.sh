#!/bin/bash -l
#SBATCH --job-name=grm
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/grm_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=12G
#SBATCH --time=24:00:00

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
saige_path=/nrnb/ukb-majithia/sarah/Git/SAIGE/extdata
#=$0 activate RSAIGE2
config=$1
#ref_config=$2

#source ${script_path}Configs/$ref_config ""

#plink_in=${outDir}${baseName}combined.LD_pruned

source ${script_path}Configs/$config ""

plink_in=${outDir}${baseName}combined.LD_pruned


echo ${SLURM_JOB_ID}" : saige_GRM.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : saige_GRM.sh : "$(date) >> \
        ${outDir}${baseName}.track



srun -l Rscript $saige_path/createSparseGRM.R       \
        --plinkFile=$plink_in \
        --nThreads=64  \
        --outputPrefix=${outDir}${baseName}sparseGRM       \
        --numRandomMarkerforSparseKin=2000      \
        --relatednessCutoff=0.125 \
	--minMAFforGRM=0.01

