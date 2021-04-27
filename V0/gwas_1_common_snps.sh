source /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/Configs/$1 $2
report_start=($(wc -l $3))

# filter for common snps
if [ $reduceVar -eq 1 ]
then
	# create list of SNPS
	extractList=${outDir}${outName}_snp_keep_list.txt
	srun -l python /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/extract_snp_list.py $snpExtract $extractList

	srun -l plink --bed ${bedfile} --bim ${bimfile} --fam ${famfile} \
	--extract $extractList \
	--freq --out ${outDir}${outName}.freq
	echo "Step\tFrequency"
	srun -l sh /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/process_log.sh $3

	echo "------------------------------>completed frequency<-----------------------"

	srun -l plink --bed ${bedfile} --bim ${bimfile} --fam ${famfile} \
	--extract $extractList \
	--freq counts --out ${outDir}${outName}.count

	echo "------------------------------>completed counts<-----------------------" 

	srun -l plink --bed ${bedfile} --bim ${bimfile} --fam ${famfile} --maf ${mafCutoff} \
	--extract $extractList \
	--make-bed --out ${outDir}${outName}.common
	echo "Step\tMAF"
	srun -l sh /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/process_log.sh $3

	echo "------------------------------>completed MAF filter<-----------------------" 


else
	srun -l plink --bed ${bedfile} --bim ${bimfile} --fam ${famfile} \
	--freq --out ${outDir}${outName}.freq
	echo "Step\tFrequency"
	srun -l sh /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/process_log.sh $3

	echo "------------------------------>completed frequency<-----------------------"

	srun -l plink --bed ${bedfile} --bim ${bimfile} --fam ${famfile} \
	--freq counts --out ${outDir}${outName}.count

	echo "------------------------------>completed counts<-----------------------" 

	srun -l plink --bed ${bedfile} --bim ${bimfile} --fam ${famfile} --maf ${mafCutoff} \
	--make-bed --out ${outDir}${outName}.common
	echo "Step\tMAF"
	srun -l sh /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/process_log.sh $3

	echo "------------------------------>completed MAF filter<-----------------------" 


fi

