#!/bin/bash -l
#SBATCH --job-name=saige2
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/saige2_%A_%a.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem=100G
#SBATCH --array=0-1

#check the help info for step 1
#Rscript step1_fitNULLGLMM.R --help
# activate RSAIGE2 environment=$0!!!

config=$1
input=$2 # 'bgen' or 'vcf'
use_preCal=$3
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
saige_path=/nrnb/ukb-majithia/sarah/Git/SAIGE/extdata
#chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)
chromosomes=(1 2)
CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}

if [ $CHR -eq 1 ]; then
echo ${SLURM_ARRAY_JOB_ID}" : run_saige_step2_rv.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_ARRAY_JOB_ID}" : run_saige_step2_rv.sh : "$(date) >> \
        ${outDir}${baseName}.track
fi

source ${script_path}Configs/$config $CHR


#grep -vw -f ${outDir}${baseName}.testedgenes ${outDir}${outName}.groupFile > \
#	${outDir}${outName}.groupFile.good


echo $outDir
echo $baseName

if [ $use_preCal -eq 1 ]; then
	in_suff=saige.preCal
else
	in_suff=saige
fi

srun -l Rscript $saige_path/step2_SPAtests.R \
	--bgenFile=${outDir}${outName}.final.bgen \
	--bgenFileIndex=${outDir}${outName}.final.bgen.bgi \
	--sampleFile=${outDir}${outName}.saige.sample \
	--GMMATmodelFile=${outDir}${baseName}$in_suff.rda \
	--varianceRatioFile=${outDir}${baseName}$in_suff.varianceRatio.txt \
	--minInfo=0.8 \
	--SAIGEOutputFile=${outDir}final_stats/${outName}.$in_suff.BGEN.stats \
	--IsOutputAFinCaseCtrl=TRUE \
	--IsOutputNinCaseCtrl=TRUE \
	--IsOutputHetHomCountsinCaseCtrl=TRUE \
	--chrom=$CHR \
	--idstoIncludeFile=${outDir}${outName}.saige.sample \
	--minMAF=0 \
	--minMAC=0.5 \
	--maxMAFforGroupTest=0.01 \
	--LOCO=FALSE \
	--groupFile=${outDir}${outName}.groupFile \
	--IsSingleVarinGroupTest=TRUE \
	--IsOutputMAFinCaseCtrlinGroupTest=TRUE \
        --cateVarRatioMinMACVecExclude='0.5,1.5,2.5,3.5,4.5,5.5,10.5,20.5' \
        --cateVarRatioMaxMACVecInclude='1.5,2.5,3.5,4.5,5.5,10.5,20.5' \
	--IsOutputPvalueNAinGroupTestforBinary=TRUE \
	--IsAccountforCasecontrolImbalanceinGroupTest=TRUE \
	--weightsIncludeinGroupFile=FALSE \
	--IsOutputBETASEinBurdenTest=TRUE \
	--method_to_CollapseUltraRare='' \
	--MACCutoff_to_CollapseUltraRare=10

