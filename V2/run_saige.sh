#!/bin/bash -l
#SBATCH --job-name=saige
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/saige_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=20
#SBATCH --mem=32G
#SBATCH --time=12:00:00

#check the help info for step 1
#Rscript step1_fitNULLGLMM.R --help
# activate RSAIGE2 environment=$0!!!

config=$1
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
saige_path=/nrnb/ukb-majithia/sarah/Git/SAIGE/extdata
source ${script_path}Configs/$config ""

echo $outDir
echo $baseName

srun -l Rscript $saige_path/step1_fitNULLGLMM.R \
	--plinkFile=${outDir}${baseName}combined.final \
	--phenoFile=${outDir}${baseName}.final.phe.cov \
	--phenoCol=PHENO \
	--covarColList=SEX,YOB,PC1,PC2,PC3,PC4,PC5 \
	--sexCol=SEX \
	--sampleIDColinphenoFile=IID \
	--traitType=binary \
	--outputPrefix=${outDir}${baseName}saige \
	--nThreads=20 \
	--LOCO=TRUE \
	--minMAFforGRM=0.01 \
	--IsOverwriteVarianceRatioFile=TRUE
