config=$1
chrom=$2
file_suff=$3
control_percent=$4 # set to 0 to keep all controls
icd10_file=$5 #set "" if not restricting to icd10 only
exclude_patt=$6 #regex of values to exclude, "" for no exclusion
hesin_file=/nrnb/ukb-majithia/20201215_hesin_diag.txt

# Get configuration values from any chromosome
source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/Configs/$config $chrom
echo ${outDir}${outName}.$file_suff.fam

# Get number of cases
n_cases=$(awk '{if ($6==2) {s++}}END{print s}' ${outDir}${outName}.$file_suff.fam)

if [ "$n_cases" > 0 ]
then
# -----------------------------
# Exclude any controls with no ICD10 codes
if [ "$icd10_file" = "" ]
then
	awk -v outfile=${outDir}${baseName}.controls.phe '{ if ($6==1) {print $1 > outfile}}' ${outDir}${outName}.$file_suff.fam
else
	awk -v outfile=${outDir}${baseName}.controls_temp.phe '{ if ($6==1) {print $1 > outfile}}' ${outDir}${outName}.$file_suff.fam
	sort -k 1 ${outDir}${baseName}.controls_temp.phe | \
		join -1 1 -2 1 \
		$icd10_file - \
		> ${outDir}${baseName}.controls.phe
	rm ${outDir}${baseName}.controls_temp.phe
fi
# Exclude comorbidities
if [ "$exclude_patt" != "" ]
then
	grep -Ev $exclude_patt $hesin_file | \
	awk '(NR>1){ a[$1]++ } END { for (b in a) { print b } }' | \
	sort | join -1 1 -2 1 ${outDir}${baseName}.controls.phe - > ${outDir}${baseName}.controls_temp.phe
	mv ${outDir}${baseName}.controls_temp.phe ${outDir}${baseName}.controls.phe
fi
# subset to number of controls desired
if [ $control_percent > 0 ]
then
	n_controls=$(expr $n_cases \* $control_percent / 100)
	echo $n_cases
	echo $n_controls
	shuf ${outDir}${baseName}.controls.phe -n $n_controls | sort | \
	awk -v out=${outDir}${baseName}.pheno.keepID '{print $1 "\t" $1 > out}'
	rm ${outDir}${baseName}.controls.phe
else
	awk -v out=${outDir}${baseName}.pheno.keepID '{print $0 "\t" $1 > out}'
	rm ${outDir}${baseName}.controls.phe
fi
	echo "Adding cases"
	cat $case_list >> ${outDir}${baseName}.pheno.keepID
else
	awk -v out=${outDir}${baseName}.pheno.keepID \
	'{print $1 "\t" $1 > out}' ${outDir}${baseName}.$file_suff.fam
# -------------------------------------------

fi
