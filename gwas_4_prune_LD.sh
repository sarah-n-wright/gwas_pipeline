source /cellar/users/snwright/Git/examples/GWAS/RunConfig.conf

echo "----------------->Prune for linkage disequilibrium<---------------------"


srun -l plink --bfile ${outDir}${outName}.hwe_dropped \
--indep-pairwise $LD_window $LD_shift $LD_r2 --make-bed \
--out ${outDir}${outName}.LD_one

srun -l plink --bfile ${outDir}${outName}.hwe_dropped \
--extract ${outDir}${outName}.LD_one.prune.in --make-bed \
--out ${outDir}${outName}.LD_two


echo "----------------->Exclude high-LD and non-autosomal regions<------------"

if [ $exclude_highLD_nonAuto -eq 1 ]
then
	awk -f $highLD ${outDir}${outName}.LD_two.bim > ${outDir}highLDexcludes
	awk '($1 < 1) || ($1 > 22) {print $2}' ${outDir}${outName}.LD_two.bim > ${outDir}autosomeexcludes
	cat ${outDir}highLDexcludes ${outDir}autosomeexcludes > ${outDir}highLD_and_autosomal_excludes
	srun -l plink --bfile ${outDir}${outName}.LD_two \
	--exclude ${outDir}highLD_and_autosomal_excludes --make-bed \
	--out ${outDir}${outName}.LD_three
else
	echo "No exclusion performed. Modify RunConfig.conf if exclusion wanted."
fi

