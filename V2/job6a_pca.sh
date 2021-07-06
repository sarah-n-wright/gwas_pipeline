#!/bin/bash -l
#SBATCH --job-name=pca
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/pca_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/pca_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=12G

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/

source ${script_path}Configs/$1 ""

if [ "$2" != "plot-only" ]
then
	srun -l plink2 --bfile ${outDir}${baseName}combined.LD_pruned \
		--keep ${outDir}${baseName}.king.keepID \
		--pca approx \
		--out ${outDir}${baseName}
else
	srun -l python plot_pca.py ${outDir}${baseName} ${baseName}
fi
