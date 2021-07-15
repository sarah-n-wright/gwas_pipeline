source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/Configs/$1 "X"

out_suff=$2
no_split=$(echo ${sex_chr[@]} | grep -c "XY") 
file_name=${outDir}${outName}.updated_phe

# Don't need this if XY region already separated?
if [ $no_split -eq 0 ]
then
	srun -l plink2 --bfile $file_name \
		--keep ${outDir}${baseName}.pheno.keepID \
		--split-par $build \
		--make-bed --out ${outDir}${outName}.sex_split${out_suff}
	file_name=${outDir}${outName}.sex_split${out_suff}
fi

# LD prune
if [ 1 -eq 1 ]
then
srun -l plink2 --bfile $file_name \
	--indep-pairwise $LD_window $LD_shift $LD_r2 \
	--out ${outDir}${outName}.sex_prune${out_suff}


srun -l plink2 --bfile $file_name \
	--extract ${outDir}${outName}.sex_prune${out_suff}.prune.in \
	--make-bed --out ${outDir}${outName}.temp${out_suff}
echo "--------------------X chromosome pruned-------------------------"


srun -l plink --bfile ${outDir}${outName}.temp${out_suff} \
	--check-sex $sexFmin $sexFmax \
	--out ${outDir}${outName}.sex_check${out_suff}

echo "--------------------Sex check performed-------------------------"


srun -l python /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/gender_check.py ${outDir}${outName}.sex_check ${outName}${out_suff}

echo "--------------------Figure plotted-------------------------"


grep "PROBLEM" ${outDir}${outName}.sex_check${out_suff}.sexcheck | \
awk '{print $1 "\t" $2}' > ${outDir}${outName}.sex_check${out_suff}.removeID

echo "--------------------Discord file created-------------------------"

grep -vxF -f ${outDir}${outName}.sex_check${out_suff}.removeID \
	${outDir}${baseName}.pheno.keepID | \
	grep -vxF -f ${outDir}${outName}.updated_phe.nosex > \
	${outDir}${baseName}.sex.keepID


fi
