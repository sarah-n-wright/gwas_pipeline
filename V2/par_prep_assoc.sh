chr=$1
impute_path=/nrnb/ukb-genetic/imputation
# Filter datasets ------------------------------------------------
echo $chr
# get the temporary filtered dataset
srun -l plink --bfile ${outDir}${baseName}chr${chr}.updated_phe \
	--remove ${outDir}${baseName}.final.removeID \
	--extract ${outDir}${baseName}chr${chr}.extractVAR \
	--make-bed --out ${outDir}${baseName}chr${chr}.final

## BOLT Specific files -------------------------------------------------------------
if [ "$assocMethod" == "BOLT" ]
then
	echo "BOLT"
## SAIGE Specific files ------------------------------------------------------------
echo "getting bgen"
elif [ "$assocMethod" == "SAIGE" ]
then
	echo $chr
	echo "SAIGE"
	# TODO - saige specific .sample file for bgen.
	# combined phenotype/covar file
	# create BGEN file from plink set
	srun -l plink2 --bfile ${outDir}${baseName}chr${chr}.final \
		--fa $fasta \
		--ref-from-fa \
		--export bgen-1.2 id-paste=iid bits=8 \
		--out ${outDir}${baseName}chr${chr}.final
	# Index the bgen file
	bgenix -g ${outDir}${baseName}chr$chr.final.bgen -index -clobber
	# create the single column sample file for SAIGE
	grep -Ev "^0 |^ID" ${outDir}${baseName}chr$chr.final.sample | \
		awk -v out=${outDir}${baseName}chr$chr.saige.sample \
		'{print $1 > out}'
	samp_file=${outDir}${baseName}chr${chr}.saige_imp.sample
	awk '(NR>2){print $1}' $impute_path/ukb_imp_chr${chr}_v3.sample | \
                grep -w -f ${outDir}${baseName}chr${chr}.saige.sample - > \
                $samp_file
else
	echo "PLINK"
fi

echo "---------------------------DONE---------------------------"

