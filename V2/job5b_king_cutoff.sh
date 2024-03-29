#!/bin/bash -l
#SBATCH --job-name=king
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/king_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/king_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=2
#SBATCH --mem=128G


script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1
source ${script_path}Configs/$config ""

echo ${SLURM_JOB_ID}" : job5b_king_cutoff.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : job5b_king_cutoff.sh : "$(date) >> \
        ${outDir}${baseName}.track

cat ${outDir}${baseName}combined.kin0.* > ${outDir}${baseName}combined.kin0

awk '(NR>1){print $1 "\t" $2 "\n" $3 "\t" $4}' \
	${outDir}${baseName}combined.kin0 | \
	sort | uniq > ${outDir}${baseName}combined.king.keepID

srun -l plink2 --bfile ${outDir}${baseName}combined.LD_pruned \
	--keep ${outDir}${baseName}combined.king.keepID \
	--maf 0.001 \
	--make-king triangle bin \
	--out ${outDir}${baseName}combined.final

srun -l plink2 --bfile ${outDir}${baseName}combined.LD_pruned \
	--king-cutoff ${outDir}${baseName}combined.final 0.125 \
	--out ${outDir}${baseName}combined

cp ${outDir}${baseName}combined.king.cutoff.out.id \
	${outDir}${baseName}.king.removeID
cp ${outDir}${baseName}combined.king.cutoff.in.id \
	${outDir}${baseName}.king.keepID
