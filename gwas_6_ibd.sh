source /cellar/users/snwright/Git/examples/GWAS/RunConfig.conf

if [ $sexInfo -eq 1 ]
then
	ld_file=${outDir}${outName}.LD_four
else
	if [ $exclude_highLD_nonAuto -eq 1 ]
	then
		ld_file=${outDir}${outName}.LD_three
	else
		ld_file=${outDir}${outName}.LD_two
	fi
fi

echo "------------------------------>Pair-wise IBD<-------------------------"

srun -l plink --bfile $ld_file --genome --make-bed \
--out ${outDir}${outName}.IBD

awk '$10 >= '$ibd' {print $1, $2}' ${outDir}${outName}.IBD.genome > ${outDir}${outName}.IBD_outliers.txt

srun -l plink --bfile ${outDir}${outName}.IBD \
--remove ${outDir}${outName}.IBD_outliers.txt --make-bed \
--out ${outDir}${outName}.no_close_relatives

echo "------------------------------>Individual Average IBD<-----------------"

$R --file=${scriptDir}IndividualIBD.R --args ${outDir}${outName} $ibd_sigma

srun -l plink --bfile $ld_file \
--remove ${outDir}${outName}.IBD_INDIV_outliers.txt --make-bed \
--out ${outDir}${outName}.LD_IBD

if [ $sexInfo -eq 1 ]
then
	srun -l plink --bfile ${outDir}${outName}.sexcheck_cleaned \
	--remove ${outDir}${outName}.IBD_INDIV_outliers.txt --make-bed \
	--out ${outDir}${outName}.IBD_cleaned
fi




