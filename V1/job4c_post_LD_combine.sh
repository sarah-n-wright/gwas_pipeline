#!/bin/bash -l
#SBATCH --job-name=post_LD
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/cad/combprune_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/cad/combprune_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=2:00:00
script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/

source ${script_path}Configs/$1 "all"

merge_file=${outDir}${outName}merge_list.txt
> $merge_file
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)

for chr in ${chromosomes[@]}
do
	echo "----------CHR "$chr"---------------------"
	srun -l plink --bfile ${outDir}${baseName}chr${chr}.variant \
	--extract ${outDir}${baseName}chr${chr}.LD_one.prune.in --make-bed \
	--allow-no-sex --out ${outDir}${baseName}chr${chr}.LD_pruned

	echo ${outDir}${baseName}chr${chr}.LD_pruned >> $merge_file
done

srun -l plink --merge-list $merge_file --allow-no-sex \
	--make-bed --out ${outDir}${outName}.LD_pruned




