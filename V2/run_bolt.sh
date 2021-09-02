#!/bin/bash -l
#SBATCH --job-name=bolt
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/bolt_%A.out
#SBATCH --partition=nrnb-gpu
#SBATCH --account=nrnb-gpu
#SBATCH --parsable
#SBATCH --cpus-per-task=40
#SBATCH --mem=100G
sed -i '1i'"${SLURM_JOB_ID} : run_bolt.sh : $(date)" "/cellar/users/snwright/Data/SlurmOut/track_slurm.txt"

# =$0 Make sure module bolt-lmm is loaded!! Run from /nrnb/ukb-majithia
config=$1
script_path=sarah/Git/gwas_pipeline/V2/
source ${script_path}Configs/$config ""
use_imputed_data=$2 # 1= yes, 0 =no
out_suff=$3 # default ""

if [ "$build" == "b37" ]
then
    g_map=BOLT-LMM_v2.3.5/tables/genetic_map_hg19_withX.txt.gz
else
    g_map=BOLT-LMM_v2.3.5/tables/genetic_map_hg38_withX.txt.gz
fi
outDir=$(echo ${outDir##*ukb-majithia/})
imputed_file_list=../ukb-genetic/imputation/bgenSampleFileList_bolt.txt

cat ${outDir}${baseName}chr*.excludeVAR > ${outDir}${baseName}.final.excludeVAR

cat ${outDir}${baseName}chr*.notInImputed.removeID | sort -k 1 | uniq > \
	${outDir}${baseName}.notInImputed.removeID

if [ "$use_imputed_data" -eq 0 ]
then
bolt \
    --bed ${outDir}${baseName}chr{1:22}.final.bed \
    --bim ${outDir}${baseName}chr{1:22}.final.bim \
    --fam ${outDir}${baseName}chr7.final.fam \
    --remove=${outDir}${baseName}.final.removeID \
    --exclude=${outDir}${baseName}.final.excludeVAR \
    --phenoFile=${outDir}${baseName}.final.phe.fam \
    --phenoCol=PHENO \
    --covarFile=${outDir}${baseName}combined.all_covariates.tsv \
    --covarCol=SEX \
    --qCovarCol=Age \
    --qCovarCol=PC{1:5} \
    --geneticMapFile=$g_map \
    --lmmForceNonInf \
    --LDscoresFile=BOLT-LMM_v2.3.5/tables/LDSCORE.1000G_EUR.tab.gz \
    --numThreads=40 \
    --statsFile=${outDir}final_stats/${baseName}.bolt$out_suff.stats
#    --modelSnps=################# \
elif [ "$use_imputed_data" -eq 1 ]
then
bolt \
    --bgenSampleFileList=$imputed_file_list \
    --bed ${outDir}${baseName}chr{1:22}.final.bed \
    --bim ${outDir}${baseName}chr{1:22}.final.bim \
    --fam ${outDir}${baseName}chr7.final.fam \
    --remove=${outDir}${baseName}.final.removeID \
    --exclude=${outDir}${baseName}.final.excludeVAR \
    --phenoFile=${outDir}${baseName}.final.phe.fam \
    --phenoCol=PHENO \
    --covarFile=${outDir}${baseName}combined.all_covariates.tsv \
    --covarCol=SEX \
    --qCovarCol=Age \
    --bgenMinMAF=0.001 \
    --bgenMinINFO=0.8 \
    --geneticMapFile=$g_map \
    --lmmForceNonInf \
    --LDscoresFile=BOLT-LMM_v2.3.5/tables/LDSCORE.1000G_EUR.tab.gz \
    --numThreads=40 \
    --statsFile=${outDir}final_stats/${baseName}.bolt_imp$out_suff.stats.gz \
    --statsFileBgenSnps=${outDir}final_stats/${baseName}.bolt_imp$out_suff.stats.bgen.gz \
    --noBgenIDcheck \
    --verboseStats \
    --remove=${outDir}${baseName}.notInImputed.removeID \
    --qCovarCol=PC{1:5}

else
	echo "invalid value for use_imputed_data"
fi
# basic args:
# --bfile: prefix of PLINK genotype files (bed/bim/fam)
# --remove: list of individuals to remove (FID IID)
# --exclude: list of SNPs to exclude (rs###)
# --phenoFile: phenotype file
# --phenoCol: column of phenotype file containing phenotypes
# --covarFile: covariate file
# --covarCol: column(s) containing categorical covariate (multiple ok)
# --qCovarCol: column(s) containing quantitative covariates (array format)
# --modelSnps: subset of SNPs to use in GRMs
# --lmm: flag to perform default BOLT-LMM mixed model association
# --LDscoresFile: reference LD Scores (data table in separate download)
# --numThreads: multi-threaded execution

# additional args for association testing on imputed SNPs:
# --statsFile: output file for association statistics at PLINK-format SNPs
# --dosageFile: file(s) containing additional dosage-format SNPs (multiple ok)
# --dosageFidIidFile: file containing FIDs and IIDs for dosage-format SNPs
# --statsFileDosageSnps: output file for assoc stats at dosage-format SNPs
# --impute2FileList: file listing chroms and IMPUTE2-format additional SNPs
# --impute2FidIidFile: file containing FIDs and IIDs for IMPUTE2-format SNPs
# --impute2CallThresh: minimum pAA+pAB+pBB for calling IMPUTE2-format SNPs
# --statsFileImpute2Snps: output file for assoc stats at IMPUTE2-format SNPs
# --dosage2FileList: file listing map and 2-dosage format additional SNPs
# --statsFileDosage2Snps: output file for assoc stats at 2-dosage format SNPs
