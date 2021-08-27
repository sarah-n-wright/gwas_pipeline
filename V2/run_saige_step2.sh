#!/bin/bash -l
#SBATCH --job-name=saige2
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/saige2_%A_%a.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=2
#SBATCH --mem=32G
#SBATCH --parsable
#SBATCH --time=2-00:00:00
#SBATCH --array=0-21

#check the help info for step 1
#Rscript step1_fitNULLGLMM.R --help
# activate RSAIGE2 environment=$0!!!

config=$1
use_imputed_data=$2 #1=yes, 0=no
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
saige_path=/nrnb/ukb-majithia/sarah/Git/SAIGE/extdata
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)
#chromosomes=(21)
CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}

if [ $CHR -eq 1 ]; then
echo ${SLURM_ARRAY_JOB_ID}" : run_saige_step2.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_ARRAY_JOB_ID}" : run_saige_step2.sh : "$(date) >> \
        ${outDir}${baseName}.track
fi

source ${script_path}Configs/$config $CHR

impute_path=/nrnb/ukb-genetic/imputation
echo $outDir
echo $baseName
if [ "$use_imputed_data" -eq 1 ]; then
awk -v out=${outDir}${outName}.saige_imp.sample \
	'(NR>2){print $1 > out}' $impute_path/ukb_imp_chr${CHR}_v3.sample

srun -l Rscript $saige_path/step2_SPAtests.R \
	--bgenFile=$impute_path/ukb_imp_chr${CHR}_v3.bgen \
	--bgenFileIndex=$impute_path/ukb_imp_chr${CHR}_v3.bgen.bgi \
	--sampleFile=${outDir}${outName}.saige_imp.sample \
	--GMMATmodelFile=${outDir}${baseName}saige.rda \
	--varianceRatioFile=${outDir}${baseName}saige.varianceRatio.txt \
	--minInfo=0.8 \
	--SAIGEOutputFile=${outDir}final_stats/${outName}.IMP.stats \
	--IsOutputAFinCaseCtrl=TRUE \
	--IsOutputNinCaseCtrl=TRUE \
	--IsOutputHetHomCountsinCaseCtrl=TRUE \
	--chrom=$CHR \
	--idstoIncludeFile=${outDir}${outName}.saige.sample \
	--IsDropMissingDosages=TRUE \
	--minMAF=0.001

elif [ "$use_imputed_data" -eq 0 ]; then
  echo "bgen"
  srun -l Rscript $saige_path/step2_SPAtests.R \
	--bgenFile=${outDir}${outName}.final.bgen \
	--bgenFileIndex=${outDir}${outName}.final.bgen.bgi \
	--sampleFile=${outDir}${outName}.saige.sample \
	--GMMATmodelFile=${outDir}${baseName}saige.rda \
	--varianceRatioFile=${outDir}${baseName}saige.varianceRatio.txt \
	--minInfo=0.8 \
	--SAIGEOutputFile=${outDir}final_stats/${outName}.BGEN.stats \
	--IsOutputAFinCaseCtrl=TRUE \
	--IsOutputNinCaseCtrl=TRUE \
	--IsOutputHetHomCountsinCaseCtrl=TRUE \
	--chrom=$CHR \
	--idstoIncludeFile=${outDir}${outName}.saige.sample \
	--minMAF=0.001

else
	echo "Invalid option for use_imputed_data"
fi
