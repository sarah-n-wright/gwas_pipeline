source ${script_path}Configs/$1 $2


echo "----------------->Prune for linkage disequilibrium<---------------------"


srun -l plink --bfile ${outDir}${outName}.LD_in \
	--hwe 0.001 --geno 0.98 --make-bed \
	--out ${outDir}${outName}.LD_zero


srun -l plink --bfile ${outDir}${outName}.LD_zero \
	--indep-pairwise $LD_window $LD_shift $LD_r2 --make-bed \
	--allow-no-sex --out ${outDir}${outName}.LD_one

echo "---------------Done indep-pairwise-------------------------"
## Getting stuck here???

srun -l plink --bfile ${outDir}${outName}.LD_in \
	--extract ${outDir}${outName}.LD_one.prune.in --make-bed \
	--allow-no-sex --out ${outDir}${outName}.LD_two


merge_file=${outDir}${outName}merge_list.txt
> $merge_file
chromosomes=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22)

for chr in ${chromosomes[@]}
do
	echo "----------CHR "$chr"---------------------"
	srun -l plink --bfile ${outDir}${baseName}chr${chr}.variant \
	--extract ${outDir}${outName}.LD_one.prune.in --make-bed \
	--allow-no-sex --out ${outDir}${baseName}chr${chr}.LD_pruned

	echo ${outDir}${baseName}chr${chr}.LD_pruned >> $merge_file
done

srun -l plink --merge-list $merge_file --allow-no-sex \
	--make-bed --out ${outDir}${outName}.LD_pruned




