source /cellar/users/snwright/Git/gwas_pipeline/Configs/$1 $2

echo "------------------------------>Performing Sex Check<-------------------------"

if [ $separate_sex -eq 1 ]
then
	file_name=${outDir}${baseName}.combined_sexCHR
else
	file_name=${bedfile%".bed"}
fi


if [ $sexInfo -eq 1 ]
then
	if test -f "${outDir}${baseName}discordant_individuals.txt"
	then
		echo "USING EXISTING DISCORDANT INDIVIDUALS"
	else
		echo "Chromosomes Present:"
		awk '{ a[$1]++ } END { for (b in a) { print b } }' ${file_name}.bim

		srun -l plink --bfile $file_name --split-x no-fail $build --make-bed \
		--out ${outDir}${baseName}.sex_split

		srun -l plink --bfile ${outDir}${baseName}.sex_split \
		--check-sex $sexFmin $sexFmax \
		--out ${outDir}${baseName}.sex_check

		## insert methods to make file discordant_individuals.txt
		touch ${outDir}${baseName}discordant_individuals.txt
	fi
	srun -l plink --bfile $file_name \
	--remove ${outDir}${baseName}discordant_individuals.txt --make-bed \
	--out ${outDir}${outName}.sexcheck_cleaned

else
	echo "Sex check turned off by RunConfig.conf"
fi



