source ${script_path}Configs/$1 $2

ld_file=${outDir}${outName}.LD_pruned

echo "------------------------------>Pair-wise IBD<-------------------------"

srun -l plink --bfile $ld_file --genome --make-bed \
	--allow-no-sex --out ${outDir}${outName}.IBD

awk '$10 >= '$ibd' {print $1, $2}' ${outDir}${outName}.IBD.genome > ${outDir}${outName}.IBD_outliers.txt

srun -l plink --bfile ${outDir}${outName}.IBD \
	--remove ${outDir}${outName}.IBD_outliers.txt --make-bed \
	--allow-no-sex --out ${outDir}${outName}.no_close_relatives

echo "------------------------------>Individual Average IBD<-----------------"

#srun -l sh ${script_path}f2_indiv_ibd.sh $1 $2

#$R --file=${scriptDir}IndividualIBD.R --args ${outDir}${outName} $ibd_sigma

#print_to=${outDir}${outName}.IBD_INDIV_outliers.remove

#awk -v out=$print_to 'BEGIN{ print "FID" "\t" "IID" > out} (NR>1) {print $2 "\t" $3 >> out}' ${outDir}${outName}.IBD_INDIV_outliers.txt

#srun -l plink --bfile $ld_file \
#--remove ${outDir}${outName}.IBD_INDIV_outliers.txt --make-bed \
#--out ${outDir}${outName}.LD_IBD

#srun -l plink --bfile ${outDir}${outName}.no_close_relatives \
#	--remove ${outDir}${outName}.IBD_INDIV_outliers.remove --make-bed \
#	--out ${outDir}${outName}.IBD_cleaned




