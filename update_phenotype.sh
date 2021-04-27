source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 $2

if [ "$case_list" = "" ]
then
	> ${outDir}${outName}.cases.phe
else
	cp $case_list ${outDir}${outName}.cases.phe
fi

srun -l plink --bed $bedfile --bim $bimfile --fam $famfile \
--make-pheno ${outDir}${outName}.cases.phe '*' \
--allow-no-sex \
--make-bed --out ${outDir}${outName}.updated_phe
