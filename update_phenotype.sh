source /cellar/users/snwright/Git/gwas_pipeline/Configs/$1 $2

# make list 
awk '{print $1 "\t" $1 > "${outDir}${outName}.cases.phe"}' $case_list

srun -l plink --bed $bedfile --bim $bimfile --fam $famfile \
--make-pheno ${outDir}${outName}.cases.phe '*' \
--out ${outDir}${outName}.updated_phe
