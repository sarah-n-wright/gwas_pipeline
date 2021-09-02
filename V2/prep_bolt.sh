#!/bin/bash -l
#SBATCH --job-name=prep_bolt
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/prep_bolt_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem=500M
#SBATCH --parsable
#SBATCH --time=00:05:00
#SBATCH --array=0-21

config=$1
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)

chr=${chromosomes[$SLURM_ARRAY_TASK_ID]}

source ${script_path}Configs/$config $chr

imputed_file=/nrnb/ukb-genetic/imputation/ukb_imp_chr${chr}_v3.sample
fam_file=${outDir}${outName}.final.fam

awk '(NR>1){print $1}' $imputed_file | sed '/^0$/d' > \
	${outDir}${outName}.imputed_samples.temp
grep -wv -f ${outDir}${outName}.imputed_samples.temp $fam_file | \
	awk -v out=${outDir}${outName}.notInImputed.removeID \
	'{print $1 "\t" $2 > out}'


