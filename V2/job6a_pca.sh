#!/bin/bash -l
#SBATCH --job-name=pca
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/pca_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/pca_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=2
#SBATCH --mem=128G

config=$1
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/

source ${script_path}Configs/$config ""

if [ "$2" != "plot-only" ]
then
	srun -l plink2 --bfile ${outDir}${baseName}combined.LD_pruned \
		--keep ${outDir}${baseName}.king.keepID \
		--thin 0.5 \
		--pca approx \
		--out ${outDir}${baseName}
#		--remove ${outDir}${baseName}.final.removeID \

else
	srun -l python plot_pca.py ${outDir}${baseName} ${baseName}
fi
