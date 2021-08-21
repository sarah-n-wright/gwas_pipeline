#!/bin/bash -l
#SBATCH --job-name=post_LD
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/combprune_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/combprune_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=64G
#SBATCH --parsable
#SBATCH --time=2:00:00

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/
config=$1

source ${script_path}Configs/$config "all"

echo ${SLURM_JOB_ID}" : job4b_post_LD_combine.sh : "$config" : "$(date) >> \
	"/cellar/users/snwright/Data/SlurmOut/track_slurm.txt"

echo ${SLURM_JOB_ID}" : job4b_post_LD_combine.sh : "$(date) >> ${outDir}${baseName}.track

merge_file=${outDir}${outName}merge_list.txt
> $merge_file
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)

for chr in ${chromosomes[@]}
do
	echo "----------CHR "$chr"---------------------"
	echo ${outDir}${baseName}chr${chr}.LD_pruned >> $merge_file
done

srun -l plink --merge-list $merge_file --allow-no-sex \
	--make-bed --out ${outDir}${baseName}combined.LD_pruned

#rm ${outDir}${baseName}chr*LD_pruned*




