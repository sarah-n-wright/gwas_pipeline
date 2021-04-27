
source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 $2

echo "------------------------------>Performing Sex Check<-------------------------"

if [ $separate_sex -eq 1 ]
then
	file_name=${outDir}${baseName}.combined_sexCHR
else
	file_name=${outDir}${outName}.updated_phe
fi


if [ $sexInfo -eq 1 ]
then
	if test -f "${outDir}${baseName}discordant_individuals.txt"
	then
		echo "USING EXISTING DISCORDANT INDIVIDUALS"
	else
		echo "Chromosomes Present:"
		awk '{ a[$1]++ } END { for (b in a) { echo b } }' ${file_name}.bim

		#srun -l plink --bfile $file_name --split-x no-fail $build --make-bed \
		#--out ${outDir}${baseName}.sex_split

		#srun -l plink --bfile ${outDir}${baseName}.sex_split \
		srun -l plink --bfile $file_name \
		--check-sex $sexFmin $sexFmax \
		--out ${outDir}${baseName}.sex_check

		srun -l python /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/gender_check.py ${outDir}${baseName}.sex_check $baseName		

		## insert methods to make file discordant_individuals.txt
		grep "PROBLEM" ${outDir}${baseName}.sex_check.sexcheck | awk '{print $1, $2}' >${outDir}${baseName}discordant_individuals.txt
	fi
	srun -l plink --bfile ${outDir}${outName}.updated_phe \
	--remove ${outDir}${baseName}discordant_individuals.txt --make-bed \
	--out ${outDir}${outName}.sexcheck_cleaned

else
	echo "Sex check turned off by RunConfig.conf"
fi



