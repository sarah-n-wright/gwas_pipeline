source /cellar/users/snwright/Git/gwas_pipeline/Configs/$1 $2

echo "------------------------------>Performing Sex Check<-------------------------"

if [ $exclude_highLD_nonAuto -eq 1 ]
then
	ld_file_suff=.LD_three
else
	ld_file_suff=.LD_two
fi

if [ $separate_sex -eq 1 ]
then
	ld_file=${outDir}${baseName}.combined_sexCHR${ld_file_suff}
else
	ld_file=${outDir}${outName}${ld_file_suff}
fi


if [ $sexInfo -eq 1 ]
then
	if test -f "${outDir}${baseName}discordant_individuals.txt"
	then
		echo "USING EXISTING DISCORDANT INDIVIDUALS"
	else
		echo "Chromosomes Present:"
		awk '{ a[$1]++ } END { for (b in a) { print b } }' ${ld_file}.bim

		srun -l plink --bfile $ld_file --split-x no-fail $build --make-bed \
		--out ${outDir}${baseName}.sex_LD_split

		srun -l plink --bfile ${outDir}${baseName}.sex_LD_split \
		--check-sex $sexFmin $sexFmax \
		--out ${outDir}${baseName}.sex_check

		## insert methods to make file discordant_individuals.txt
		touch ${outDir}${baseName}discordant_individuals.txt
	fi
	srun -l plink --bfile $ld_file \
	--remove ${outDir}${baseName}discordant_individuals.txt --make-bed \
	--out ${outDir}${outName}.LD_four

	srun -l plink ${outDir}${outName}.hwe_dropped \
	--remove ${outDir}${baseName}discordant_individuals.txt --make-bed \
	--out ${outDir}${outName}.sexcheck_cleaned

else
	echo "Sex check turned off by RunConfig.conf"
fi



