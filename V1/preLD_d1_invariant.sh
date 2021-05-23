source ${script_path}Configs/$1 $2
#report_start=($(wc -l $3))

file_pref=${outDir}${outName}.hwe_dropped

srun -l plink --bfile $file_pref \
	--freq --out ${outDir}${outName}.freq
echo "Step\tFrequency"
#srun -l sh process_log.sh $3

echo "------------------------------>completed frequency<-----------------------"

srun -l plink --bfile $file_pref \
	--freq counts --out ${outDir}${outName}.count

echo "------------------------------>completed counts<-----------------------" 

srun -l plink --bfile  $file_pref \
	--make-bed --out ${outDir}${outName}.variant
echo "Step\tMAF"
#srun -l sh /nrnb/ukb-majithia/sarah/Git/gwas_pipeline/process_log.sh $3

echo "------------------------------>completed MAF filter<-----------------------" 

