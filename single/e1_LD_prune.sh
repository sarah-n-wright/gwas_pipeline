source ${script_path}Configs/$1 $2

suff=$3

echo "----------------->Prune for linkage disequilibrium<---------------------"


srun -l plink --bfile ${outDir}${outName}.${suff} \
	--hwe 0.001 --geno 0.98 --make-bed \
	--out ${outDir}${outName}.LD_zero


srun -l plink --bfile ${outDir}${outName}.LD_zero \
	--indep-pairwise $LD_window $LD_shift $LD_r2 --make-bed \
	--out ${outDir}${outName}.LD_one

echo "---------------Done indep-pairwise-------------------------"
## Getting stuck here???

srun -l plink --bfile ${outDir}${outName}.${suff} \
	--extract ${outDir}${outName}.LD_one.prune.in --make-bed \
	--out ${outDir}${outName}.LD_pruned



