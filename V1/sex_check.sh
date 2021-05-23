source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 "X"

suff=$2
no_split=$(echo ${sex_chr[@]} | grep -c "XY") 
file_name=${outDir}${outName}.updated_phe
if [ $case_list != "" ]
then
	file_name=${outDir}${outName}.CC
fi
echo $file_name

# Don't need this if XY region already separated?
if [ $no_split -eq 0 ]
then
	srun -l plink --bfile $file_name \
		--split-x no-fail $build \
		--allow-no-sex \
		--make-bed --out ${outDir}${outName}.sex_split${suff}
	file_name=${outDir}${outName}.sex_split${suff}
fi

# LD prune
if [ 1 -eq 1 ]
then
srun -l plink --bfile $file_name \
	--indep-pairphase $LD_window $LD_shift $LD_r2 \
	--out ${outDir}${outName}.sex_prune${suff}


srun -l plink --bfile $file_name \
	--extract ${outDir}${outName}.sex_prune${suff}.prune.in \
	--make-bed --out ${outDir}${outName}.temp${suff}
echo "--------------------X chromosome pruned-------------------------"


srun -l plink --bfile ${outDir}${outName}.temp${suff} \
	--check-sex $sexFmin $sexFmax \
	--out ${outDir}${outName}.sex_check${suff}

echo "--------------------Sex check performed-------------------------"


srun -l python /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V1/gender_check.py ${outDir}${outName}.sex_check ${outName}${suff}

echo "--------------------Figure plotted-------------------------"


grep "PROBLEM" ${outDir}${outName}.sex_check${suff}.sexcheck | \
awk '{print $1, $2}' > ${outDir}${outName}discordant_individuals${suff}.txt

echo "--------------------Discord file created-------------------------"

fi
