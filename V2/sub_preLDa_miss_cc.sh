source ${script_path}Configs/$1 $2

if [ "$case_list" = "" ]
then
	echo "No phenotypes present"
else
	in_file=${outDir}${outName}.updated_phe

	srun -l plink --bfile $in_file \
		--keep ${outDir}${baseName}.miss.keepID \
		--exclude ${outDir}${outName}.excludeVAR \
		--test-missing \
		--out ${outDir}${outName}_cc

	mkdir ${outDir}final_stats/
	mv ${outDir}${outName}_cc.missing ${outDir}final_stats/
	awk -v out=${outDir}final_stats/${outName}_cc.sig.missing \
		'BEGIN { getline; print $0 } {if ($5 < 0.001) {print $0 > out} }' \
		${outDir}final_stats/${outName}_cc.missing
fi
