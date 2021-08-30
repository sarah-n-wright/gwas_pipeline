#!/bin/bash -l
#SBATCH --job-name=saige
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/saige_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=60
#SBATCH --mem=100G
#SBATCH --parsable
#SBATCH --time=2-00:00:00

#check the help info for step 1
#Rscript step1_fitNULLGLMM.R --help
# activate RSAIGE2 environment=$0!!!

config=$1
use_pruned=$2
use_imp_check_cov_file=$3
out_suff=$4
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
saige_path=/nrnb/ukb-majithia/sarah/Git/SAIGE/extdata
source ${script_path}Configs/$config ""

echo ${SLURM_JOB_ID}" : run_saige.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : run_saige.sh : "$(date) >> \
        ${outDir}${baseName}.track

echo $outDir
echo $baseName

if [ $use_pruned -eq 1 ]; then
        in_file=${outDir}${baseName}combined.LD_pruned
else
        in_file=${outDir}${baseName}combined.final
fi

if [ $use_imp_check_cov_file -eq 1 ]; then
	cov_file=${outDir}${baseName}.imp.phe.cov
else
	cov_file=${outDir}${baseName}.final.phe.cov
fi

srun -l Rscript $saige_path/step1_fitNULLGLMM.R \
	--plinkFile=$in_file \
	--phenoFile=$cov_file \
	--phenoCol=PHENO \
	--covarColList=SEX,Age \
	--sexCol=SEX \
	--sampleIDColinphenoFile=IID \
	--traitType=binary \
	--outputPrefix=${outDir}${baseName}saige$out_suff \
	--nThreads=60 \
	--LOCO=TRUE \
	--minMAFforGRM=0.01 \
	--IsOverwriteVarianceRatioFile=TRUE
