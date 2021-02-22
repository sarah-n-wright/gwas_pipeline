source /cellar/users/snwright/Git/examples/GWAS/RunConfig.conf

echo "------------------------------>Performing Sex Check<-------------------------"

if [ $exclude_highLD_nonAuto -eq 1 ]
then
	ld_file=${outDir}${outName}.LD_three
else
	ld_file=${outDir}${outName}.LD_two
fi


if [ $sexInfo -eq 1 ]
then
	echo "Chromosomes Present:"
	awk '{ a[$1]++ } END { for (b in a) { print b } }' $bimfile

	srun -l plink --bfile $ld_file --split-x no-fail $build --make-bed \
	--out ${outDir}${outName}.LD_split

	srun -l plink --bfile ${outDir}${outName}.LD_split \
	--check-sex $sexFmin $sexFmax \
	--out ${outDir}${outName}.sex_check

	## insert methods to make file discordant_individuals.txt
	touch ${outDir}${outName}_discordant_individuals.txt

	srun -l plink --bfile $ld_file \
	--remove ${outDir}${outName}_discordant_individuals.txt --make-bed \
	--out ${outDir}${outName}.LD_four

	srun -l plink ${outDir}${outName}.hwe_dropped \
	--remove ${outDir}${outName}_discordant_individuals.txt --make-bed \
	--out ${outDir}${outName}.sexcheck_cleaned

else
	echo "Sex check turned off by RunConfig.conf"
fi



