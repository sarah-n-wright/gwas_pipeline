#!/bin/bash -l
#SBATCH --job-name=pca
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/pca_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/pca_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G

config=$1
#=$2 provide 'plot-only' if wanted, otherwise blank
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/

source ${script_path}Configs/$config ""

echo ${SLURM_JOB_ID}" : job6a_pca.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : job6a_pca.sh : "$(date) >> \
        ${outDir}${baseName}.track

grep -w -f /nrnb/ukb-majithia/data/phenotypes/ukb_f22006_white_caucasian_eids.txt \
        ${outDir}${baseName}.king.keepID > ${outDir}${baseName}.temp.keepID


if [ "$2" != "plot-only" ]
then
	srun -l plink2 --bfile ${outDir}${baseName}combined.LD_pruned \
		--keep ${outDir}${baseName}.temp.keepID \
		--thin 0.5 \
		--pca approx \
		--out ${outDir}${baseName}
#		--remove ${outDir}${baseName}.final.removeID \

else
	srun -l python plot_pca.py ${outDir}${baseName} ${baseName}
fi
