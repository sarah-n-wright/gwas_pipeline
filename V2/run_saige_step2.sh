#!/bin/bash -l
#SBATCH --job-name=saige2
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/saige2_%A_%a.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=6:00:00
#SBATCH --array=0-21
#check the help info for step 1
#Rscript step1_fitNULLGLMM.R --help
# activate RSAIGE2 environment=$0!!!

config=$1
input=$2 # 'bgen' or 'vcf'
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
saige_path=/nrnb/ukb-majithia/sarah/Git/SAIGE/extdata
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)
#chromosomes=(21)
CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}

source ${script_path}Configs/$config $CHR

echo $outDir
echo $baseName

if [ "$input" == "bgen" ]
then
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

elif [ "$input" == "vcf" ]
then
echo "vcf"
srun -l Rscript $saige_path/step2_SPAtests.R \
	--vcfFile=${outDir}${outName}.final.vcf.gz \
	--vcfFileIndex=${outDir}${outName}final.vcf.gz.csi \
	--vcfField=GT \
	--GMMATmodelFile=${outDir}${baseName}saige.rda \
	--varianceRatioFile=${outDir}${baseName}saige.varianceRatio.txt \
	--minInfo=0.8 \
	--SAIGEOutputFile=${outDir}final_stats/${outName}.VCF.stats \
	--IsOutputAFinCaseCtrl=TRUE \
	--IsOutputNinCaseCtrl=TRUE \
	--IsOutputHetHomCountsinCaseCtrl=TRUE \
	--chrom=$CHR \
	--idstoIncludeFile=${outDir}${outName}.saige.sample \
	--minMAF=0.001

fi
