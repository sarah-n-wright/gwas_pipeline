source ${script_path}Configs/$1 $2

echo "----------------->Prune for linkage disequilibrium<---------------------"

# Remove highLD from extractVAR
awk -f $highLD ${outDir}${outName}.updated_phe.bim > \
	${outDir}${outName}.highLD.excludeVAR
grep -vwF -f ${outDir}${outName}.highLD.excludeVAR \
	${outDir}${outName}.extractVAR > ${outDir}${outName}.LD_in.extractVAR

# Run LD
srun -l plink2 --bfile ${outDir}${outName}.updated_phe \
	--keep ${outDir}${baseName}.LD_subset.keepID \
	--extract ${outDir}${outName}.LD_in.extractVAR \
	--indep-pairwise $LD_window $LD_shift $LD_r2 \
	--allow-no-sex --out ${outDir}${outName}

srun -l plink2 --bfile ${outDir}${outName}.updated_phe \
	--keep ${outDir}${baseName}.miss.keepID \
	--extract ${outDir}${outName}.prune.in \
	--make-bed \
	--out ${outDir}${outName}.LD_pruned

echo "---------------Done indep-pairwise-------------------------"
## Getting stuck here???


