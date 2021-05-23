#!/bin/bash -l
#SBATCH --job-name=assoc_prep
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/assoc_prep_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/assoc_prep_%A.err
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

covariates=/nrnb/ukb-majithia/epilepsy/phenotypes/cov_sorted.tsv
pcs=${outDir}${outName}.pca2.eigenvec

sed 's/\s/\t/g' $pcs | sort -k 1 -o ${outDir}${outName}.pca.pcs.sorted

join -1 1 -2 1 $covariates ${outDir}${outName}.pca.pcs.sorted | \
	sed 's/\s/\t/g' | \
	cut -f1,2,3,4,6- > ${outDir}${outName}.all_covariates.tsv

chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)

merge=${outDir}${baseName}final_merge.txt
> $merge

for chr in ${chromosomes[@]}
do
	srun -l plink --bfile ${outDir}${baseName}chr${chr}.variant \
		--keep ${outDir}${outName}.no_close_relatives.fam \
		--remove ${outDir}${baseName}chr${chr}.updated_phe.nosex \
		--maf 0.001 \
		--make-bed --out ${outDir}${baseName}chr${chr}.QCed
	echo ${outDir}${baseName}chr${chr}.QCed >> $merge
done

srun -l plink --merge-list $merge --allow-no-sex \
	--make-bed --out ${outDir}${outName}.QCed

echo "---------------------------DONE---------------------------"

#srun -l plink --bfile ${outDir}${outName} \
#	--logisitic --covar ${outDir}${outName}.all_covariates.tsv \
#	--covar-number 2-12 --allow-no-sex \
#	--out ${outDir}${outName}.assoc
