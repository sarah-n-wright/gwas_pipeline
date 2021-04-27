source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 "X"
xPref=${outDir}${outName}.updated_phe
source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 "Y"
yPref=${outDir}${outName}.updated_phe
echo "------------------------------>Combining sex chrs<-------------------------"

### Check if sex chromosome info is split across files.

if [ $separate_sex -eq 1 ]
then
	if test -f "${outDir}${baseName}.combined_sexCHR.bed"
	then
		echo "COMBINED SEX FILES ALREADY EXIST."
	else
# if it is merge the bed files
		merge_list=${outDir}${baseName}.combine_sexCHR_merge_list.txt
		> $merge_list
		echo $yPref.bed $yPref.bim $yPref.fam >> $merge_list
		#source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 "XY"
		#if test -f $bedfile
		#then
			#source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 "XY"
			#xyPref=${outDir}${outName}.updated_phe
			#echo $xyPref.bed $xyPref.bim $xyPref.fam >> $merge_list
		#fi
		srun -l plink -bfile $xPref \
		--merge-list $merge_list --allow-no-sex \
		--make-bed --out ${outDir}${baseName}.combined_sexCHR
	fi
fi
