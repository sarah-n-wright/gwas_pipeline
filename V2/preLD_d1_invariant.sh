source ${script_path}Configs/$1 $2
#report_start=($(wc -l $3))

file_pref=${outDir}${outName}.updated_phe

srun -l plink2 --bfile $file_pref \
	--keep ${outDir}${baseName}.miss.keepID \
	--exclude ${outDir}${outName}.excludeVAR \
	--freq --out ${outDir}final_stats/${outName}
echo "Step\tFrequency"
#srun -l sh process_log.sh $3

echo "------------------------------>completed frequency<-----------------------"

srun -l plink2 --bfile $file_pref \
	--keep ${outDir}${baseName}.miss.keepID \
	--exclude ${outDir}${outName}.excludeVAR \
	--freq counts --out ${outDir}final_stats/${outName}

echo "------------------------------>completed counts<-----------------------" 

srun -l plink2 --bfile  $file_pref \
	--keep ${outDir}${baseName}.miss.keepID \
	--exclude ${outDir}${outName}.excludeVAR \
	--maf $minMAF --max-maf $maxMAF \
	--make-just-bim --out ${outDir}${outName}.extractVAR

awk -v out=${outDir}${outName}.extractVAR '{print $2 > out}' \
	${outDir}${outName}.extractVAR.bim

rm ${outDir}${outName}.extractVAR.bim

echo "Step\tMAF"
#srun -l sh /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/process_log.sh $3

echo "------------------------------>completed MAF filter<-----------------------" 

rm ${outDir}final_stats/${outName}*.log
rm ${outDir}final_stats/${outName}*.nosex
rm ${outDir}${outName}*.log
rm ${outDir}${outName}*.nosex
