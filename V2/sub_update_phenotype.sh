source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/V2/Configs/$1 $2
cases=$3

if [ "$cases" == "" ]
then
	> ${outDir}${outName}.cases.phe
	cases=${outDir}${outName}.cases.phe
	remove_cases=1
else
	remove_cases=0
fi

if [ "$ancestry_subset" == "" ]
then
	awk -v out=${outDir}${outName}.anc.phe \
	'{print $1 "\t" $2 > out}' $famfile
else
	awk -v out=${outDir}${outName}.anc.phe \
	'{print $1 "\t" $1 > out}' $ancestry_subset
fi
ancestry_keep=${outDir}${outName}.anc.phe

srun -l plink --bed $bedfile --bim $bimfile --fam $famfile \
	--keep $ancestry_keep \
	--make-pheno $cases '*' \
	--allow-no-sex \
	--make-bed --out ${outDir}${outName}.updated_phe

if [ $remove_cases -eq 1 ]
then
	rm $cases
fi

rm $ancestry_keep
