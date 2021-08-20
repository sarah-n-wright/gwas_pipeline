#!/bin/bash -l
#SBATCH --job-name=saige
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/saige_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=60
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00


#check the help info for step 1
#Rscript step1_fitNULLGLMM.R --help
# activate RSAIGE2 environment=$0!!!

config=$1
pre_cal=$2
use_pruned=$3
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
saige_path=/nrnb/ukb-majithia/sarah/Git/SAIGE/extdata
source ${script_path}Configs/$config ""

echo ${SLURM_JOB_ID}" : run_saige_rv.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : run_saige_rv.sh : "$(date) >> \
        ${outDir}${baseName}.track
echo $outDir
echo $baseName

if [ $use_pruned -eq 1 ]; then
	in_file=${outDir}${baseName}combined.LD_pruned
else
	in_file=${outDir}${baseName}combined.final
fi

if [ $pre_cal -eq 1 ]; then

srun -l Rscript $saige_path/step1_fitNULLGLMM.R \
	--plinkFile=$in_file \
	--phenoFile=${outDir}${baseName}.final.phe.cov \
	--phenoCol=PHENO \
	--covarColList=SEX,Age,PC1,PC2,PC3,PC4 \
	--sexCol=SEX \
	--sampleIDColinphenoFile=IID \
	--traitType=binary \
	--outputPrefix=${outDir}${baseName}saige.preCal \
	--nThreads=60 \
	--minMAFforGRM=0.01 \
	--IsOverwriteVarianceRatioFile=TRUE \
	--isCateVarianceRatio=TRUE \
	--cateVarRatioMinMACVecExclude='0.5,1.5,2.5,3.5,4.5,5.5,10.5,20.5' \
	--cateVarRatioMaxMACVecInclude='1.5,2.5,3.5,4.5,5.5,10.5,20.5' \
	--useSparseGRMtoFitNULL=TRUE \
	--useSparseSigmaConditionerforPCG=TRUE \
	--sparseGRMFile=${outDir}${baseName}sparseGRM_relatednessCutoff_0.125_2000_randomMarkersUsed.sparseGRM.mtx \
	--sparseGRMSampleIDFile=${outDir}${baseName}sparseGRM_relatednessCutoff_0.125_2000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt \
	--IsSparseKin=FALSE

else

srun -l Rscript $saige_path/step1_fitNULLGLMM.R \
	--plinkFile=$in_file \
	--phenoFile=${outDir}${baseName}.final.phe.cov \
	--phenoCol=PHENO \
	--covarColList=SEX,Age,PC1,PC2,PC3,PC4 \
	--sexCol=SEX \
	--sampleIDColinphenoFile=IID \
	--traitType=binary \
	--outputPrefix=${outDir}${baseName}saige \
	--nThreads=60 \
	--minMAFforGRM=0.01 \
	--IsOverwriteVarianceRatioFile=TRUE \
	--isCateVarianceRatio=TRUE \
	--cateVarRatioMinMACVecExclude='0.5,1.5,2.5,3.5,4.5,5.5,10.5,20.5' \
	--cateVarRatioMaxMACVecInclude='1.5,2.5,3.5,4.5,5.5,10.5,20.5'

fi
