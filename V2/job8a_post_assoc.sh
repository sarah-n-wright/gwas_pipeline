#!/bin/bash -l
#SBATCH --job-name=post_assoc
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/post_assoc_%A.out
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --parsable
#SBATCH --mem=4G
#SBATCH --time=1:00:00

config=$1
method=$2 # BOLT or SAIGE
input=$3 # file type for saige'bgen' or 'vcf' or 'imputed'
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
source ${script_path}Configs/$config ""

echo ${SLURM_JOB_ID}" : job8a_post_assoc.sh : "$config" : "$(date) >> \
        /cellar/users/snwright/Data/SlurmOut/track_slurm.txt

echo ${SLURM_JOB_ID}" : job8a_post_assoc.sh : "$(date) >> \
        ${outDir}${baseName}.track


if [ "$method" == "SAIGE" ]
then
 if [ "$input" == 'bgen' ]
 then
 head -1 ${outDir}final_stats/${baseName}chr1.BGEN.stats > \
 	${outDir}final_stats/${baseName}combined.BGEN.stats && \
	tail -n +2 -q ${outDir}final_stats/${baseName}chr*.BGEN.stats >> \
	${outDir}final_stats/${baseName}combined.BGEN.stats
	gzip ${outDir}final_stats/${baseName}combined.BGEN.stats
 elif [ "$input" == 'imputed' ]
 then
 head -1 ${outDir}final_stats/${baseName}chr1.IMP.stats > \
 	${outDir}final_stats/${baseName}combined.IMP.stats && \
	tail -n +2 -q ${outDir}final_stats/${baseName}chr*.IMP.stats >> \
	${outDir}final_stats/${baseName}combined.IMP.stats
	gzip -f ${outDir}final_stats/${baseName}combined.IMP.stats
 elif [ "$input" == 'vcf' ]
 then
 head -1 ${outDir}final_stats${baseName}chr1.VCF.stats > \
	${outDir}final_stats${baseName}combined.VCF.stats && \
	tail -n +2 -q ${outDir}final_stats${baseName}chr*.VCF.stats >> \
	${outDir}final_stats${baseName}combined.VCF.stats
	gzip ${outDir}final_stats/${baseName}combined.BGEN.stats
 else
 echo "Invalid file input for SAIGE:"$input
 fi
elif [ "$method" ~ "BOLT" ]
then
	echo "Add bolt things if neccessary"
else
 echo "Invalid method option:"$method
fi
