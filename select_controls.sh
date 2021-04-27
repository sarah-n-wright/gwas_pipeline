source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 $2
echo ${outDir}${outName}.updated_phe.fam

n_cases=$(awk '{if ($6==2) {s++}}END{print s}' ${outDir}${outName}.updated_phe.fam)
control_percent=150

if [ "$n_cases" > 0 ]
then
	n_controls=$(expr $n_cases \* $control_percent / 100)
	echo $n_cases
	echo $n_controls
	awk -v outfile=${outDir}${baseName}.controls.phe '{ if ($6==1) {print $1 "\t" $1 > outfile}}' ${outDir}${outName}.updated_phe.fam
	shuf ${outDir}${baseName}.controls.phe -o ${outDir}${baseName}.case_control.keep -n $n_controls
	cat $case_list >> ${outDir}${baseName}.case_control.keep
fi
