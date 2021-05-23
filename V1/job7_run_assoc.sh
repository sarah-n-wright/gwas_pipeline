#!/bin/bash -l
#SBATCH --job-name=assoc
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/assoc_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/assoc_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=64G
#SBATCH --time=12:00:00
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/
#chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 'X' 'Y')
#chromosomes=(21)
config=$1
#CHR=${chromosomes[$SLURM_ARRAY_TASK_ID]}
out=$v1_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_JOB_ID}.out

source ${script_path}Configs/$config all

covariates=${outDir}${outName}.all_covariates.tsv

srun -l plink --bfile ${outDir}${outName}.QCed \
	--logistic beta hide-covar --covar ${outDir}${outName}.all_covariates.tsv \
	--covar-number 2-10 --allow-no-sex \
	--out ${outDir}${outName}.log

echo "---------------------------DONE ASSOC-Logistic-------------------------"

srun -l plink --bfile ${outDir}${outName}.QCed \
	--assoc --covar ${outDir}${outName}.all_covariates.tsv \
	--covar-number 2-10 --allow-no-sex \
	--out ${outDir}${outName}
