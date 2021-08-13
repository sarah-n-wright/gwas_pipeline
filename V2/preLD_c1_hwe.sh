source ${script_path}Configs/$1 $2

in_file=${outDir}${outName}.updated_phe

# check results of missingnesss?
srun -l plink --bfile $in_file \
	--keep ${outDir}${baseName}.miss.keepID \
	--exclude ${outDir}${outName}.excludeVAR \
	--missing \
	--out ${outDir}${outName}.filtered_missing_check

echo "------------------>Check lowest call rates for variants<----------------"
echo "No variants should have more than "${missEnd}"% in column 5"

sort -k 5 -gr ${outDir}${outName}.filtered_missing_check.lmiss | head

echo "------------------>Check lowest call rates for individuals<-------------"
echo "No individuals should have more than "$missEnd"% missing in column 6"

sort -k 6 -gr ${outDir}${outName}.filtered_missing_check.imiss | head

rm ${outDir}${outName}.filtered_missing_check*

# HWE tests on controls
echo "------------------>Hardy Weinberg Equilibrium<--------------------------"

srun -l plink --bfile $in_file \
	--keep ${outDir}${baseName}.miss.keepID \
	--exclude ${outDir}${outName}.excludeVAR \
	--hardy --out ${outDir}final_stats/${outName}

echo "----------------->Finished HWE Equilibrium<-----------------------------"

rm ${outDir}final_stats/${outName}*.log
#rm ${outDir}final_stats/${outName}*.nosex
