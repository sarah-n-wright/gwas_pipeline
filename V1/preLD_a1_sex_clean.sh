source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 $2

if [[ $3 == "reverse" ]]
then
	keep_file=$4
	if [ $case_list != "" ]
	then
	srun -l plink --bfile ${outDir}${outName}.CC \
		--keep $keep_file --make-bed \
		--out ${outDir}${outName}.sexcheck_cleanedCC
	fi
	srun -l plink --bfile ${outDir}${outName}.updated_phe \
		--keep $keep_file --make-bed \
		--out ${outDir}${outName}.sexcheck_cleaned
else
	if [ $sexInfo -eq 1 ]
	then
		if [ $case_list != "" ]
		then
		srun -l plink --bfile ${outDir}${outName}.CC \
			--remove ${outDir}${baseName}chrXdiscordant_individuals.txt --make-bed \
			--out ${outDir}${outName}.sexcheck_cleanedCC
		fi
		srun -l plink --bfile ${outDir}${outName}.updated_phe \
			--remove ${outDir}${baseName}chrXdiscordant_individuals.txt --make-bed \
			--out ${outDir}${outName}.sexcheck_cleaned
	fi
fi
