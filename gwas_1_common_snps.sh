source /cellar/users/snwright/Git/gwas_pipeline/Configs/$1 $2

# filter for common snps
srun -l plink --bed ${bedfile} --bim ${bimfile} --fam ${famfile} \
--freq --out ${outDir}${outName}.freq

echo "------------------------------>completed frequency<-----------------------"

srun -l plink --bed ${bedfile} --bim ${bimfile} --fam ${famfile} \
--freq counts --out ${outDir}${outName}.count

echo "------------------------------>completed counts<-----------------------" 

srun -l plink --bed ${bedfile} --bim ${bimfile} --fam ${famfile} --maf ${mafCutoff} \
--make-bed --out ${outDir}${outName}.common

echo "------------------------------>completed MAF filter<-----------------------" 
