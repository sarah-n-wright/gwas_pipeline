source ${script_path}Configs/$1 $2

if [ "$case_list" = "" ]
then
	echo "No phenotypes present"
else
	in_file=${outDir}${outName}.CC

	srun -l plink --bfile $in_file --test-missing --out ${outDir}${outName}_test_cc

	mkdir ${outDir}final_stats/
	mv ${outDir}${outName}_test_cc.missing ${outDir}final_stats/
fi
