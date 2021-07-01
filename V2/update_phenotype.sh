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

srun -l plink --bed $bedfile --bim $bimfile --fam $famfile \
	--make-pheno $cases '*' \
	--allow-no-sex \
	--make-bed --out ${outDir}${outName}.updated_phe

if [ $remove_cases -eq 1 ]
then
	rm $cases
fi
