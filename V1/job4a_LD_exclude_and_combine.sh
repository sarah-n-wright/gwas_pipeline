#!/bin/bash -l
#SBATCH --job-name=LD_excl
#SBATCH --output /cellar/users/snwright/Data/SlurmOut/ex1_%A.out
#SBATCH --error /cellar/users/snwright/Data/SlurmOut/ex1_%A.err
#SBATCH --partition=nrnb-compute
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G
#SBATCH --time=2:00:00

script_path=/nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/
source ${script_path}Configs/$1 all

chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)

# get subset of individuals
shuf -n 10000 ${outDir}${baseName}chr1.variant.fam > ${outDir}${outName}.LD_subset.fam

srun -l plink --bfile ${outDir}${baseName}chr1.variant  \
        --keep ${outDir}${outName}.LD_subset.fam  \
        --make-bed --out ${outDir}${outName}.LD_subset

merge_file=${outDir}${baseName}merge_list.txt
> $merge_file

# Exlude high LD regions and subset to number of individuals

for chr in ${chromosomes[@]}
do
	echo "----starting "$chr"-----------"
	awk -f $highLD ${outDir}${baseName}chr${chr}.variant.bim > highLD.exclude.bim
	srun -l plink --bfile ${outDir}${baseName}chr${chr}.variant \
	--keep ${outDir}${outName}.LD_subset.fam \
	--exclude highLD.exclude.bim --make-bed \
	--out ${outDir}${baseName}chr${chr}.exclude.reduced
	#if [ chr -gt 1 ]
	echo ${outDir}${baseName}chr${chr}.exclude.reduced >> $merge_file
	#fi
done

if [[ $2 == 1 ]]
then
# Merge data together
echo "*************************************MERGE******************************"
srun -l plink --merge-list $merge_file --allow-no-sex \
	--make-bed --out ${outDir}${outName}.LD_in
fi
covariates=/nrnb/ukb-majithia/epilepsy/phenotypes/cov_sorted.tsv # File clean up
rm highLD.exclude.bim
#rm ${outDir}${baseName}chr*.exclude.reduced*
#rm $merge_list
