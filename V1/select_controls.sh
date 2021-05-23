source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 $2
echo ${outDir}${outName}.$3.fam

n_cases=$(awk '{if ($6==2) {s++}}END{print s}' ${outDir}${outName}.$3.fam)
control_percent=200

if [ "$n_cases" > 0 ]
then
	n_controls=$(expr $n_cases \* $control_percent / 100)
	echo $n_cases
	echo $n_controls
	awk -v outfile=${outDir}${baseName}.controls.phe '{ if ($6==1) {print $1 > outfile}}' ${outDir}${outName}.$3.fam
	sort -k 1 ${outDir}${baseName}.controls.phe | \
		join -1 1 -2 1 \
		/nrnb/ukb-majithia/epilepsy/inputs/any_icd10_sorted.txt - \
		> ${outDir}${baseName}.controls.icd10.phe
	#epilepsy/inputs/any_icd10_410869.txt
	shuf ${outDir}${baseName}.controls.icd10.phe -o ${outDir}${baseName}.case_control.keep -n $n_controls
	cat $case_list >> ${outDir}${baseName}.case_control.keep
fi
