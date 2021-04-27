source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 $2

echo "------------------------------>Combining sex chrs<-------------------------"

if [ $exclude_highLD_nonAuto -eq 1 ]
then
	ld_file_suff=.LD_three
else
	ld_file_suff=.LD_two
fi

### Check if sex chromosome info is split across files.

if [ $separate_sex -eq 1 ]
then
	if test -f "${outDir}${outName}.combined_sexCHR.bed"
	then
		echo "COMBINED SEX FILES ALREADY EXIST."
	else
# if it is merge the bed files
		merge_list=${outDir}${baseName}.combine_sexCHR_merge_list.txt
		touch $merge_list
		echo ${outDir}${baseName}chrY${ld_file_suff}.bed ${outDir}${baseName}chrY${ld_file_suff}.bim ${outDir}${baseName}chrY${ld_file_suff}.fam >> $merge_list
		if test -f "${outDir}${baseName}chrXY${ld_file_suff}.bed"
		then
			echo ${outDir}${baseName}chrXY${ld_file_suff}.bed ${outDir}${baseName}chrXY${ld_file_suff}.bim ${outDir}${baseName}chrXY${ld_file_suff}.fam >> $merge_list
		fi
		srun -l plink -bfile ${outDir}${baseName}chrX${ld_file_suff} \
		--merge-list $merge_list \
		--make-bed --out ${outDir}${baseName}.combined_sexCHR${ld_file_suff}
	fi
fi
